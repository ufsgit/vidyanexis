import re

with open(r'C:\Users\ASUS\.gemini\antigravity-ide\brain\bf11b301-6a0c-4938-8ca2-f4de60264539\full_prompt.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# Extract job_sheet_page.dart
page_match = re.search(r'"(import \'package:bodhie/constants/app_colors.dart\'.*?\})"\s+this is "job_sheet_page\.dart"', content, re.DOTALL)
if page_match:
    page_code = page_match.group(1)
    page_code = page_code.replace('package:bodhie', 'package:vidyanexis')
    with open(r'd:\dev\vidyanexis\lib\presentation\pages\home\job_sheet_page.dart', 'w', encoding='utf-8') as out:
        out.write(page_code)
    print('Wrote job_sheet_page.dart')
else:
    print('Could not find job_sheet_page.dart')

# Extract job_sheet_model.dart
model_match = re.search(r'and\s+"(import \'package:flutter/material\.dart\';.*?\})"\s+this is "job_sheet_model\.dart"', content, re.DOTALL)
if model_match:
    model_code = model_match.group(1)
    model_code = model_code.replace('package:bodhie', 'package:vidyanexis')
    with open(r'd:\dev\vidyanexis\lib\controller\models\job_sheet_model.dart', 'w', encoding='utf-8') as out:
        out.write(model_code)
    print('Wrote job_sheet_model.dart')
else:
    print('Could not find job_sheet_model.dart')

# Extract job_sheet_provider.dart
provider_match = re.search(r'and also\s+"(import \'dart:ui\';.*)$', content, re.DOTALL)
if provider_match:
    provider_code = provider_match.group(1)
    provider_code = re.sub(r'</USER_REQUEST>.*', '', provider_code, flags=re.DOTALL).strip()
    if provider_code.endswith('"'):
        provider_code = provider_code[:-1]
    provider_code = provider_code.replace('package:bodhie', 'package:vidyanexis')
    with open(r'd:\dev\vidyanexis\lib\controller\job_sheet_provider.dart', 'w', encoding='utf-8') as out:
        out.write(provider_code)
    print('Wrote job_sheet_provider.dart')
else:
    print('Could not find job_sheet_provider.dart')
