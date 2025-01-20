# Projects Roulette

A dynamic and interactive roulette wheel application designed to randomly select projects or tasks. Available in both web (React) and mobile (Flutter) versions, offering the same core functionality with platform-specific optimizations.

## Features

- **Interactive Wheel**: Smooth spinning animation with realistic physics
- **Bilingual Support**: Full support for English and Spanish
- **Project Display**: Clear visualization of project titles on the wheel
- **Result Display**: Elegant modal/dialog showing the selected project details
- **History Tracking**: Keep track of previously selected projects
- **Responsive Design**: Works seamlessly on different screen sizes
- **Modern UI**: Clean and intuitive interface with a modern design

## Technical Stack

### Web Version (React)
- React.js with Hooks
- Tailwind CSS for styling
- Lucide React for icons
- Custom SVG implementation for the wheel

### Mobile Version (Flutter)
- Flutter framework
- Custom Painters for wheel rendering
- Material Design components
- Animation controllers for smooth transitions

## API Integration

Both versions connect to a REST API endpoint:
```
https://sticky-notes-week-1.onrender.com/api/notes
```

The API provides:
- Project titles
- Project descriptions
- Other relevant metadata

## Installation

### Web Version (React)
1. Clone the repository
2. Navigate to the `frontendWebReact` directory
3. Install dependencies:
   ```bash
   npm install
   ```
4. Run the development server:
   ```bash
   npm run dev
   ```

### Mobile Version (Flutter)
1. Clone the repository
2. Navigate to the `frontendMobile` directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. Launch the application
2. Wait for the projects to load from the API
3. Click/Tap the wheel to start spinning
4. The wheel will spin and randomly select a project
5. View the selected project's details in the result dialog
6. Access history through the menu to see previously selected projects
7. Change language settings as needed through the settings menu

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
