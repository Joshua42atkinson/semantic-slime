import re

def get_grade_word(aoa):
    if aoa < 8: return "3-5"
    if aoa <= 12: return "6-8"
    return "9-12"

def get_grade_synonym(diff):
    if diff == 1: return "3-5"
    if diff == 2: return "6-8"
    return "9-12"

def process_word(match):
    content = match.group(0)
    aoa_match = re.search(r'AoA\s*=\s*(\d+)', content)
    if aoa_match:
        grade = get_grade_word(int(aoa_match.group(1)))
        # find the last key-value pair and add a comma
        return content[:-1] + f",\n\t\tGradeLevel = \"{grade}\"\n\t}}"
    return content

def process_syn(match):
    content = match.group(0)
    diff_match = re.search(r'Difficulty\s*=\s*(\d+)', content)
    if diff_match:
        grade = get_grade_synonym(int(diff_match.group(1)))
        return content[:-1] + f",\n\t\tGradeLevel = \"{grade}\"\n\t}}"
    return content

# Read files
with open("src/shared/WordDatabase.lua", "r") as f:
    word_content = f.read()

word_res = re.sub(r'\["[^"]+"\]\s*=\s*\{[^}]+\}', process_word, word_content)

with open("src/shared/WordDatabase.lua", "w") as f:
    f.write(word_res)

with open("src/shared/SynonymDatabase.lua", "r") as f:
    syn_content = f.read()

syn_res = re.sub(r'\["[^"]+"\]\s*=\s*\{[^}]+\}', process_syn, syn_content)

with open("src/shared/SynonymDatabase.lua", "w") as f:
    f.write(syn_res)

print("Done")
