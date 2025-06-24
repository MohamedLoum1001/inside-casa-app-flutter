# Étape 1 : Builder Flutter Web
FROM cirrusci/flutter:stable AS build

WORKDIR /app

# Copier les sources Flutter dans le conteneur
COPY . .

# Installer les dépendances Flutter
RUN flutter pub get

# Compiler pour le Web en mode release
RUN flutter build web --release

# Étape 2 : Image nginx pour servir l’app Web
FROM nginx:alpine

# Copier le build web dans le dossier servi par nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose le port 80
EXPOSE 80

# Commande par défaut pour démarrer nginx
CMD ["nginx", "-g", "daemon off;"]
