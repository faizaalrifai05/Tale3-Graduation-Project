import os
import re

directory = r"c:\Users\Lenovo\Desktop\testtale3\lib\screens"

replacements = {
    # Brand
    r"(?<!AppStyles\.)const Color\(0xFF8B1A2B\)": "AppStyles.primaryColor",
    r"(?<!AppStyles\.)Color\(0xFF8B1A2B\)": "AppStyles.primaryColor",
    r"(?<!AppStyles\.)const Color\(0xFF5C0A1A\)": "AppStyles.darkMaroon",
    r"(?<!AppStyles\.)Color\(0xFF5C0A1A\)": "AppStyles.darkMaroon",
    # Text
    r"(?<!AppStyles\.)const Color\(0xFF1A1A1A\)": "AppStyles.textPrimary",
    r"(?<!AppStyles\.)Color\(0xFF1A1A1A\)": "AppStyles.textPrimary",
    r"(?<!AppStyles\.)const Color\(0xFF757575\)": "AppStyles.textSecondary",
    r"(?<!AppStyles\.)Color\(0xFF757575\)": "AppStyles.textSecondary",
    r"(?<!AppStyles\.)const Color\(0xFF9E9E9E\)": "AppStyles.textTertiary",
    r"(?<!AppStyles\.)Color\(0xFF9E9E9E\)": "AppStyles.textTertiary",
    # Border
    r"(?<!AppStyles\.)const Color\(0xFFE0E0E0\)": "AppStyles.borderColor",
    r"(?<!AppStyles\.)Color\(0xFFE0E0E0\)": "AppStyles.borderColor",
    # Background
    r"(?<!AppStyles\.)const Color\(0xFFF5F5F5\)": "AppStyles.cardBackgroundColor",
    r"(?<!AppStyles\.)Color\(0xFFF5F5F5\)": "AppStyles.cardBackgroundColor",
}

import_statement = "import 'package:testtale3/theme/app_styles.dart';"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original_content = content

    # Replace local static consts that might have been created
    content = content.replace("static const Color _primaryColor = Color(0xFF8B1A2B);", "")
    content = content.replace("static const Color _primaryColor = AppStyles.primaryColor;", "")
    content = content.replace("static const Color _darkMaroon = Color(0xFF5C0A1A);", "")
    content = content.replace("static const Color _darkMaroon = AppStyles.darkMaroon;", "")
    
    # Replace usages
    content = content.replace("_primaryColor", "AppStyles.primaryColor")
    content = content.replace("_darkMaroon", "AppStyles.darkMaroon")
    
    for pattern, replacement in replacements.items():
        content = re.sub(pattern, replacement, content)
        
    if content != original_content:
        # Add import if not present
        if import_statement not in content:
            first_import_index = content.find("import ")
            if first_import_index != -1:
                content = content[:first_import_index] + import_statement + "\n" + content[first_import_index:]
            else:
                content = import_statement + "\n\n" + content
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filepath}")

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith(".dart"):
            process_file(os.path.join(root, file))
