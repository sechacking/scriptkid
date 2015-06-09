#!/usr/bin/env python
#coding=utf-8
#by robert
"""
1、密码长度在8-12位之间
2、密码全是数字
3、密码全是小写字母
4、密码全是大写字母
5、密码中存在连续相同的数字或字母，并且数量大于3，例如1111、aaaa
6、密码中存在连续数字，并且长度超过3个，例如1234、4567

详情见:http://drops.cnmoker.org/archives/361.html
"""
import sys
import re

def is_legal_pwd(pwd):
    for idx, s in enumerate(pwd):
        if s.isdigit() and pwd[idx:idx+4].isdigit() and int(pwd[idx:idx+4]) - int(s*4) == 123: return False

def pass_rule():
    newfile=open("c:\\newpass.txt", 'w')
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
                    else:
                        newfile.writelines(line + '\n')

pass_rule()