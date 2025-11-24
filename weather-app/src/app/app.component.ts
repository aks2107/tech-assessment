import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { environment } from '../environments/environment';

/*
This is the interface which defines the data to get from weather API.
*/
interface WeatherData {
  // Information about location and the place
  location: {
    name: string;
    region: string;
    country: string;
  };
  // Information about current temperature in Celisius and Fahreinheit
  // Icon and icon description based on current temperature
  current: {
    temp_c: number;
    temp_f: number;
    condition: {
      text: string;
      icon: string;
    };
  };
  // Temperature forecast for the next day in Celisius and Fahreinheit
  // Icon and icon description based on tommorow's temperature
  forecast: {
    forecastday: Array<{
      date: string;
      day: {
        avg_c: number;
        avg_f: number;
        condition: {
          text: string;
          icon: string;
        };
      };
    }>;
  };
}