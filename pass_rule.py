import sys
import re
import str

def is_legal_pwd(pwd):
    for idx, s in enumerate(pwd):
        if s.isdigit() and pwd[idx:idx+4].isdigit() and int(pwd[idx:idx+4]) - int(s*4) == 123: return False

def pass_rule():
    newfile=open("c:\\newpass.txt", 'wb')
    for line in open("c:\\csdn_pwd_top30000.txt"):
        line=str(line).strip()
        if 13>len(line)>7:
            if not line.isdigit():
                if line.isalpha():
                    if not line.islower():
                        if not line.isupper():
                            newfile.writelines(line+'\n')
                elif not re.search(r'(\w)\1{3,}',line):
                    if re.search('\d{4,}',line):
                        if is_legal_pwd(line)!=False:
                            newfile.writelines(line+'\n')

pass_rule()