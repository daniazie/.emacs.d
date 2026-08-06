from argparse import ArgumentParser
import pypandoc

if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--text', type=str)
    parser.add_argument('--convert_from', type=str)
    parser.add_argument('--convert_to', type=str])
    args = parser.parse_args()

    converted_text = pypandoc.convert_text(args.text, to=args.convert_to, format=args.convert_from)
    print(converted_text)
