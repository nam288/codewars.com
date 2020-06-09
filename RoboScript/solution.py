#!/usr/bin/python
# -*- coding: utf-8 -*-
from collections import defaultdict, deque, namedtuple
import re


def union_reg(*r):
    return re.compile('|'.join('{}'.format(s) for s in r))


class RSUSyntaxError(Exception):

    pass


class RSURuntimeError(Exception):

    pass


class Sequence:

    def __init__(
        self,
        head,
        body,
        tail,
        level=0,
        scope=None,
        ):
        self.level = level
        self.body = body
        self.time = (1 if len(tail) == 1 else int(tail[1:]))
        self.scope = scope[:]
        self.parent = None

    def set_root(self, root):
        self.root = root
        for cmd in self.body:
            cmd.set_root(root)

    def set_parent(self, parent):
        for cmd in self.body:
            cmd.parent = parent
            if isinstance(cmd, (Sequence, Command)):
                cmd.set_parent(parent)

    def execute(self):
        if self.time == 0:
            return ''
        return ''.join(cmd.execute() for cmd in self.body) * self.time


class Pattern:

    def __init__(
        self,
        head,
        body,
        tail,
        level=0,
        scope=None,
        ):
        self.id = head[1:]
        self.body = body
        self.scope = scope[:]
        self.level = level
        self.parent = None
        self.isCalled = False
        self.root = None

    def set_root(self, root):
        self.root = root
        for child in self.body:
            child.set_root(root)

    def set_parent(self):
        for child in self.body:
            child.parent = self
            if isinstance(child, Pattern):
                child.set_parent()
            elif isinstance(child, (Sequence, Command)):
                child.set_parent(self)

    def reset(self):
        self.isCalled = False
        for child in self.body:
            if isinstance(child, Pattern):
                child.reset()

    def get_children(self):
        self.children = []
        for cmd in self.body:
            if isinstance(cmd, Pattern):
                self.children.append(cmd)
                cmd.get_children()

        # check duplicate pattern id

        children_ids = [child.id for child in self.children]
        if len(set(children_ids)) != len(children_ids):
            raise RuntimeError('2 patterns are defined with the same name in a scope'
                               )

    def execute(self):
        if self.isCalled:
            raise RSURuntimeError('Infinite recursion')
        self.isCalled = True
        res = ''.join(cmd.execute() for cmd in self.body
                      if not isinstance(cmd, Pattern))
        self.reset()
        return res


class Command:

    def __init__(self, value, scope):
        self.value = value
        self.scope = scope[:]
        self.parent = None
        self.type = ('normal' if value[0] != 'P' else 'invoking')
        self.n = (1 if len(value) == 1 else int(value[1:]))

    def set_root(self, root):
        self.root = root

    def set_parent(self, parent):
        self.parent = parent

    def execute(self):
        if self.type == 'normal':
            return (self.value[0] * self.n if self.n != 0 else '')

        parent = self.parent
        while parent:
            for child in parent.children:
                if isinstance(child, Pattern) and child.id \
                    == str(self.n):
                    return child.execute()
            parent = parent.parent

        for ptn in self.root:
            if isinstance(ptn, Pattern) and ptn.id == str(self.n):
                return ptn.execute()
        raise RSURuntimeError('Non-existent pattern with id: {}'.format(self.n))


class RSUProgram:

    def __init__(self, source):
        self.source = source + '\n'

    def get_tokens(self):

        VOCABULARY = r"[FRLPpq\(\)]"
        COMMENT = r"(?ms)/\*.*?\*/|//[^\n]*\n"
        NUMBER = r"\d+"
        SPACE = r"[ \t\n\r]+"

        def taste(*r):
            if not raw_tokens:
                return False
            return re.fullmatch(union_reg(*r), raw_tokens[0])

        def eat():
            tokens.append((raw_tokens[0] if not taste(NUMBER) else tokens.pop()
                          + raw_tokens[0]))
            raw_tokens.popleft()

        if re.search('|'.join('(?P<{}>{})'.format(*pair) for pair in
                     [('LeadingZero', r"\D0\d+"), ('StrayComment',
                     '[^{}]'.format(VOCABULARY)), ('StrayNumber',
                     r"(/\*.*?\*/|\s+)\d+"), ('PatternWithoutIdentifier'
                     , r"[pP](?!\d+)")]), re.sub(COMMENT, ' ',
                     self.source)):
            raise RSUSyntaxError()

        raw_tokens = deque(re.findall(union_reg(COMMENT, VOCABULARY,
                           NUMBER, SPACE, r"."), self.source))
        tokens = []

        while raw_tokens:
            if taste(VOCABULARY):
                eat()
                if taste(NUMBER):
                    eat()
            elif taste(COMMENT, SPACE):
                raw_tokens.popleft()
            else:
                raise RSUSyntaxError('Invalid character')

        return tokens

    def get_program(self, tokens):
        R1 = {'command': {'regex': r"([FLRP])(\d*)",
              'terminator': None}, 'sequence': {'regex': r"\(",
              'terminator': r"\)\d*"},
              'pattern': {'regex': r"(p)(\d*)", 'terminator': 'q'}}

        R2 = '|'.join('(?P<{}>{})'.format(k, v['regex']) for (k, v) in
                      R1.items())

        def taste(r):
            if not tokens:
                return False
            return re.fullmatch(r, tokens[0])

        def get_token(level=0, scope=None):
            m = re.fullmatch(R2, tokens[0])
            if not m:
                raise RSUSyntaxError()
            kind = m.lastgroup
            head = m.group(0)

            tokens.popleft()

            if kind == 'command':
                return Command(head, scope)

            body = []
            while not taste(R1[kind]['terminator']):
                body.append(get_token(level + 1, (scope
                            + [head[1:]] if kind == 'pattern'
                             else scope)))

            if not tokens:
                raise RSUSyntaxError()
            tail = tokens.popleft()

            if kind == 'pattern':
                return Pattern(head, body, tail, level, scope)
            else:
                return Sequence(head, body, tail, level, scope)

        program = []

        while tokens:
            program.append(get_token(0, []))

        return program

    def validate_token_list(self, tokens):
        s = ''.join(tokens)

        if re.search(r"p[^q]*$", s):
            raise RSURuntimeError('Pattern definition doesnt close')

        while True:
            m = re.search(r"\([^\(\)]*\)", s)
            if not m:
                break
            if re.search(r"[pq]", m.group(0)):
                raise RSURuntimeError('Brackets and/or pattern definition tokens are unmatched'
                        )
            s = re.sub(r"\([^\(\)]*\)", '', s)

        if re.search(r"[\(\)]", s):
            raise RSURuntimeError('Not match open/close bracket')

    def config(self, program):
        root = []
        for cmd in program:
            cmd.set_root(root)
            if isinstance(cmd, Pattern):
                cmd.root = root
                root.append(cmd)
                cmd.get_children()
                cmd.set_parent()

        root_pattern_ids = [ptn.id for ptn in root if isinstance(ptn,
                            Pattern)]
        if len(set(root_pattern_ids)) != len(root_pattern_ids):
            raise RSURuntimeError('2 patterns are defined with the same name in root scope'
                                  )

    def reset(self, program):
        for cmd in program:
            if isinstance(cmd, Pattern):
                cmd.reset()

    def convert_to_raw(self, tokens):
        tokens = deque(tokens)
        self.validate_token_list(tokens)
        program = self.get_program(tokens)
        self.config(program)

        res = ''
        for cmd in program:
            if not isinstance(cmd, Pattern):
                self.reset(program)
                res += cmd.execute()

        return list(res)

    def execute_raw(self, cmds):
        code = ''.join(cmds)

        (x, y, dx, dy) = (0, 0, 1, 0)
        path = [[x, y]]

        for c in re.sub(r"(L|R|F)(\d+)", lambda m: m[1] * int(m[2]),
                        code):
            if c == 'L':
                (dx, dy) = ((dy, 0) if dy else (0, -dx))
            elif c == 'R':
                (dx, dy) = ((-dy, 0) if dy else (0, dx))
            else:
                x += dx
                y += dy
                path.append([x, y])

        (min_x, min_y) = map(min, [[cell[i] for cell in path] for i in
                             range(2)])

        path = [[cell[0] - min_x, cell[1] - min_y] for cell in path]

        (max_x, max_y) = map(max, [[cell[i] for cell in path] for i in
                             range(2)])

        res = [[' ' for _ in range(max_x + 1)] for _ in range(max_y
               + 1)]
        for (x, y) in path:
            res[y][x] = '*'
        return '\r\n'.join([''.join(x) for x in res])

    def execute(self):
        return self.execute_raw(self.convert_to_raw(self.get_tokens()))
