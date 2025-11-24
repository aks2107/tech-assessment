# WeatherApp

This project is a weather application built with Angular and Tailwind CSS. This app allows users to search for a city's current weather conditions, the forecast for the next day, and switch between Celsius and Fahrenheit.

## Features:

- Search for a city's weather forecast by name.
- View current forecast and icon image with description.
- View tomorrow's forecast.
- Switch between Celsius and Fahrenheit.

## Important Prerequisites:

Before you begin, make sure the following is installed:

- Node.js 
- Angular CLI

### Installation:

Clone the repository:
```
git clone https://github.com/aks2107/tech-assessment.git
cd weather-app
```

Install the Dependencies:
```
npm install
```

### API Key:
This project uses WeatherAPI.com. Without an API key this program will not work.

1. Get a free API Key:
    - Sign up with an account at WeatherAPI.com.
    - Copy your API Key from the dashboard.

2. Setup Environment File:
    - Go to the src/environments/ folder.
    - Locate the file named environment.example.ts.
    - Copy this file into environment.ts.
        ```
        cp src/environments/environment.example.ts src/environments/environment.ts
    - Open the environment.ts file
    - Replace the placeholder text ```'YOUR_API_KEY_HERE'``` with your API key.

### How to Run Locally:

1. Start the server by typing this into terminal
    ```
    ng serve 
    ```

2. Open the app:
    - Open your browser and go to ```http://localhost:4200```
    - If the app is missing buttons and looks plain, do the following:
        - Check if Tailwind CSS is installed correctly.
        - Do ```Ctrl + C``` in terminal to close app.
        - Run ```ng serve``` again.

#### Contact Information:
- Email: abinswar7@gmail.com
- LinkedIn: https://www.linkedin.com/in/aveinn-swar/
