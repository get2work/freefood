#!/bin/bash

# Create directories if they don't exist
mkdir -p assets/map_styles
mkdir -p web/icons

# Generate logos
flutter run -d chrome --dart-define=GENERATE_LOGOS=true

# Copy map styles
cat > assets/map_styles/light_map_style.json << 'EOL'
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#f5f5f5"}]
  },
  // ... rest of light style ...
]
EOL

cat > assets/map_styles/dark_map_style.json << 'EOL'
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  // ... rest of dark style ...
]
EOL

# Create favicon
cp web/icons/Icon-192.png web/favicon.png 