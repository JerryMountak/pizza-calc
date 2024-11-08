
# Pizza Dough Calculator
<div align="center">

![License](https://img.shields.io/badge/license-MIT-green)
![Flutter Version](https://img.shields.io/badge/flutter-3.24.3-blue)
![Dart Version](https://img.shields.io/badge/Dart-3.5.3-%230175C0)
![Platform Support](https://img.shields.io/badge/Platforms-iOS%2C%20Android%2C%20Windows-blue)
![Version](https://img.shields.io/github/v/release/JerryMountak/pizza-calc)





</div>


This Flutter application helps users calculate the ingredients for pizza dough based on customizable inputs, such as hydration levels, yeast types, and other parameters. It also supports theme switching and stores recipes in a local SQLite database.

## Features

- **Dynamic Ingredient Calculation:** Automatically calculates ingredient quantities based on user inputs.
- **Custom Recipe Storage:** Save, load, and modify recipes stored in an SQLite database.
- **Theme Switching:** Switch between light and dark themes with dynamic color support.
- **Ingredient Validation:** Handles various validations for pizza ingredient inputs.
- **Responsive UI:** Built using Material 3 components for modern and adaptive design.

## Getting Started

To get started with this project, you’ll need to clone the repository and install dependencies.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.24.3 or higher
- [SQLite](https://www.sqlite.org/) (for storing recipes)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/JerryMountak/pizza-calc.git
   cd pizza-calc
   ```

2. Install the dependencies:

   ```bash
   flutter pub get
   ```

3. Run the application:

   ```bash
   flutter run
   ```

## Folder Structure

```
lib/
├── main.dart             # Main entry point of the app
├── models/               # Data models (e.g., Recipe, Ingredient)
├── providers/            # State management (e.g., ThemeProvider)
├── screens/              # UI Screens (e.g., Home, RecipePage)
├── services/             # Database interaction (e.g., SQLite queries)
├── widgets/              # Reusable widgets (e.g., IngredientInput, RecipeCard)
└── utils/                # Utility functions (e.g., input validation)
```

## Usage

- **Input Customization:** Adjust parameters such as hydration level, yeast type, etc.
- **Save Recipes:** Store your favorite recipes for future use.
- **Switch Themes:** Toggle between light and dark themes for personalized app appearance.

## Contributing

Contributions are welcome! If you find a bug or want to add a feature, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the Flutter team for the amazing framework.
- Special thanks to Material Design for their component library.
