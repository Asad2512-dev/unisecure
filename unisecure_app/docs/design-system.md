# Design system

The application is light mode only: off-white surfaces, navy typography, blue primary actions, restrained borders and soft rounded cards. Status colors are reserved for meaningful success, warning and danger states. Theme colors, typography, labels and endpoint names are centralized under `lib/app/theme` and `lib/app/config`.

No `AlertDialog`, `Dialog`, modal bottom sheet or dialog-style container is used. Forms and feedback are inline or full-screen routes. The login action shows progress inside its button and validation remains inline.
