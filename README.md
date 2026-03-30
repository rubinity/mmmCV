# mmmCV - First Step

A simple CV generator that creates ODT files from user data stored in CSV format.

## Features (Step 1)

- **User Input**: First name, optional middle name, last name, and note
- **Data Storage**: CSV file for persistent storage
- **Output**: ODT file compatible with Google Docs and LibreOffice
- **Format**: Full name in ALL CAPS, empty line, note with capital first letter

## Project Structure

```
mmmCV/
├── bin/
│   └── cv_generator.dart          # Console application
├── lib/
│   ├── models/
│   │   └── user_data.dart          # User data model
│   └── services/
│       ├── csv_service.dart        # CSV file operations
│       └── odt_service.dart        # ODT file generation
└── pubspec.yaml                    # Dependencies
```

## How to Run (Console Version)

```bash
cd mmmCV
dart bin/cv_generator.dart
```

## Usage

1. **Add user data** - Enter name and note information
2. **View existing data** - See all stored user records
3. **Generate CV** - Create ODT file from selected user data
4. **Exit** - Quit the application

## Output Format

The generated ODT file contains:

```
FULL NAME IN ALL CAPS

Note with capital first letter
```

## Next Steps

- [ ] Add Flutter GUI interface
- [ ] Improve ODT generation with proper ZIP structure
- [ ] Add more CV fields (email, phone, etc.)
- [ ] Add multiple CV templates
- [ ] Add mobile support

## Compatibility

- **Google Docs**: Can import and edit the generated ODT files
- **LibreOffice**: Native support for ODT format
- **Microsoft Word**: Can open ODT files with good compatibility
