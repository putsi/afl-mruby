import os
import codecs
import markdown
from github import Github
from bs4 import BeautifulSoup
from mdx_gfm import GithubFlavoredMarkdownExtension

# Prerequisites:
# pip install pygithub
# pip install markdown
# pip install pip install py-gfm

# First create a Github instance.
# NOTE: This requires that Github user API token is set as env variable.
g = Github(os.environ['GITHUB_API_TOKEN'])

# Get all MRuby/MRuby repo issues.
mruby = g.get_repo('mruby/mruby')
issues = mruby.get_issues(state="all")

for issue in issues:
    body = issue.body
    if not body:
        # Someone was lazy and did not provide description for issue...
        continue
    # Somewhat ugly way to get all code blocks as iterable.
    # First convert to html and then get all html code-tags as a list.
    html = markdown.markdown(body, extensions=[GithubFlavoredMarkdownExtension()])
    soup = BeautifulSoup(html)
    # Some issues have multiple code blocks so keep note of that.
    i = 0
    for code_tag in soup.find_all('code'):
        # Try to get rid of as much non-code content as possible.
        ignore_block_keywords = [
          "==ERROR: AddressSanitizer:",
          "SUMMARY: AddressSanitizer:",
          "% bin/mruby",
          "% ruby ",
          "% mruby ",
          "#define ",
          "#include ",
          "pc=0x",
          "MRuby::Build",
          "diff --git ",
          "(lldb)",
          "CFLAGS=",
          "LDFLAGS=",
          "Backtrace:",
          "minirake",
          "$ echo",
          "$ ruby",
          "HEAP SUMMARY",
          "$ mruby",
          "Invalid write of size",
          "git ",
          "undefined reference",
          "--- a",
          "$ rake",
          "$ uname"
        ]

        if any(keyword in code_tag.text for keyword in ignore_block_keywords):
            # Skipping code block as it most likely doesn't contain testcase.
            continue
        i += 1
        # Save current code block to testcases/issuenumber-codeblockindex.txt
        fn = "testcases/" + str(issue.number) + "-" + str(i) + ".txt"
        try:
            file = open(fn, 'r')
            print "File for " + fn + " already existed, skipping codeblock!"
            continue
        except IOError:
            # Let's make the file UTF-8 just in case.
            with codecs.open(fn,'w',encoding='utf8') as file:
                if type(code_tag.text) == str:
                    value = unicode(code_tag.text, "utf-8", errors="ignore")
                else:
                    value = unicode(code_tag.text)
                file.write(value)
                print "Wrote " + fn + " as not existed"
                file.close()
