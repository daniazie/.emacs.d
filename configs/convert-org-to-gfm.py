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
import pypandoc
import argparse
import os
import re


# %%
def convert_headings(string):
    pattern = re.compile(r"^# (.+?)\s*$", re.MULTILINE)
    repl = r"### \1"
    string_decomposed = string.splitlines()
    for i, line in enumerate(string_decomposed):
        string_decomposed[i] = re.sub(pattern, repl, line)
    return '\n'.join(string_decomposed)

# %%
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--org', type=str)
    args = parser.parse_args()
    text = pypandoc.convert_text(args.org, to="gfm", format="org")
    print(convert_headings(text))
