import unittest

import pcre2


class MatchTestCase(unittest.TestCase):
    def setUp(self):
        pass

    def test_abc(self):
        p = pcre2.PCRE2(r'hello.+'.encode())
        match = p.search('this is hello world.'.encode())
        self.assertIsNotNone(match)
        match = p.search('this should be not found.'.encode())
        self.assertIsNone(match)

    def test_group(self):
        content = 'this is hello world.'.encode()

        p = pcre2.PCRE2('hello.+'.encode())
        match = p.search(content)
        self.assertEqual(match.group(0), b'hello world.')

        p = pcre2.PCRE2(r'(hello)(.+)'.encode())
        match = p.search(content)
        self.assertEqual(match.group(0), b'hello world.')
        self.assertEqual(match.group(1), b'hello')
        self.assertEqual(match.group(2), b' world.')
        self.assertListEqual(match.groups(), [b'hello', b' world.'])

    def test_chinese(self):
        content = '我来到北京敏感词广场，请遵守中华人民共和国法律.'.encode()
        p = pcre2.PCRE2(r'共和国.+'.encode())
        match = p.search(content)
        self.assertEqual(match.group(0), '共和国法律.'.encode())

        p = pcre2.PCRE2(r'(北京)(\w+)广场'.encode())
        match = p.search(content)
        self.assertIsNone(match)

        p = pcre2.PCRE2(r'(北京)(\w+)广场'.encode(), pcre2.UTF | pcre2.UCP)
        match = p.search(content)
        self.assertEqual(match.group(0), '北京敏感词广场'.encode())
        self.assertEqual(match.group(1), '北京'.encode())
        self.assertEqual(match.group(2), '敏感词'.encode())
        self.assertListEqual(
            match.groups(), ['北京'.encode(), '敏感词'.encode()])

if __name__ == '__main__':
    unittest.main()
