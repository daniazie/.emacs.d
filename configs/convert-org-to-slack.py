# ---
# jupyter:
#   jupytext:
#     cell_metadata_filter: -all
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.19.3
#   kernelspec:
#     display_name: base
#     language: python
#     name: python3
# ---

# %%
from markdown_to_mrkdwn import SlackMarkdownConverter
import argparse
import os
import re

# %%
converter = SlackMarkdownConverter()

def read_file(md_file):
    file = open(md_file, "r", encoding="utf-8")
    return file.read()

# %%
def convert_headings(string):
    pattern = re.compile(r"^# (.+?)\s*$", re.MULTILINE)
    repl = r"**%d. \1**"
    string_decomposed = string.splitlines()
    n = 1
    for i, line in enumerate(string_decomposed):
        numbered = re.sub(pattern, repl, line)
        if not numbered == line:
            string_decomposed[i] = numbered % n
            n+=1
    return '\n'.join(string_decomposed)

# %%
def convert_md_to_slack(md_text):
    md_text = convert_headings(md_text)
    mrkdwn_text = converter.convert(md_text)
    slack_msg = "*[주간보고]*\n" + mrkdwn_text.strip()
    return slack_msg


# %%
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--md', type=str)
    args = parser.parse_args()
    if os.path.exists(args.md):
        md_text = read_file(args.md)
    else:
        md_text = args.md
    slack_msg = convert_md_to_slack(md_text)
    print(slack_msg)
