# The Curator's Compendium - Website

This document provides a comprehensive overview of "The Curator's Compendium," a static website designed as a personal archive of foundational and influential media.

## Overview

"The Curator's Compendium" is a non-commercial, personal tribute to influential video games, literature, series, movies, and characters. It serves as a living document to catalog works that have shaped the author's perspective or defined genres. The website explicitly states it is not a collection of reviews but a tribute to the creators and their worlds. The last update to the site was on September 26, 2025.

## Key Features

* **Side Navigation**: A fixed vertical navigation bar provides quick access to different media categories using icons. Categories include Home, Video Games, Literature, Series & Movies, and Characters.
* **Hero Section**: The homepage features a prominent hero section that introduces the website's purpose and welcomes visitors to the collection.
* **Artistic Grid Layout**: Each category displays its items in an artistic and responsive grid. The grid uses a mix of standard, tall, and wide cards to create a visually engaging layout.
* **Interactive Cards**: On hover, each item card displays a "zoom in" effect on its image, while the title fades out to reveal a detailed description of the work.
* **Custom Typography**: The site uses 'Cormorant Garamond' for headings and 'Inter' for body text, sourced from Google Fonts, to create a sophisticated and readable aesthetic.
* **Animated Background**: The website features a subtle, animated "nebula" background created with layered radial gradients that shift over time.

## Content Highlights

* **Video Games**: This section includes titles like *Elden Ring*, *Bloodborne*, *Sekiro*, *Slay the Princess*, *Horizon Zero Dawn*, and *Hollow Knight*.
* **Literature**: Features foundational works such as *Lord of the Rings*, the *Cradle Series*, the *Harry Potter Series*, *Sherlock Holmes*, *The Hunger Games*, and the *Percy Jackson* series.
* **Web Series & Movies**: This category highlights productions like *Arcane*, *The Blacklist*, *Castlevania*, *Loki*, *V for Vendetta*, and *Chernobyl*.
* **Characters**: Showcases iconic characters, including The Endless from *Sandman*, Doctor Doom, Lucifer Morningstar, John Constantine, Ghost Rider, Etrigan the Demon, and V from *V for Vendetta*.

## Technical Implementation

* **Frontend**: The website is built with standard HTML5 and CSS3.
* **External Libraries**: It utilizes Font Awesome for iconography.
* **Styling**: The CSS is structured with variables for colors and fonts, and it includes responsive design adjustments for tablet and mobile devices. On smaller screens (max-width: 768px), the side navigation is hidden, and the multi-column grid collapses into a single column.

## Deployment & Automation (CI/CD)

The website is deployed and maintained using a fully automated CI/CD pipeline on AWS, defined by several key configuration files.

### Pipeline Infrastructure

* **Orchestration**: AWS CodePipeline manages the workflow from source to deployment.
* **Build Process**: AWS CodeBuild is used to prepare the artifacts for deployment. The `buildspec.yml` file instructs the build process to make all scripts executable and then package all source files into an artifact.
* **Deployment Target**: The infrastructure is provisioned by AWS CloudFormation, deploying the website to an EC2 instance running Ubuntu 22.04 with an Apache2 web server.
* **Deployment Management**: AWS CodeDeploy handles the application deployment on the EC2 instance, managed by the `appspec.yml` file.

### `appspec.yml` Configuration

* **File Destination**: The `appspec.yml` file specifies that `index.html`, `style.css`, and the `/images` directory are to be placed in the `/var/www/html` directory on the server.

### Deployment Lifecycle Hooks

The deployment process is managed by a series of scripts executed in a specific order to ensure a safe and reliable update:
1.  **`ApplicationStop`**: The `stop_server.sh` script stops the Apache2 service.
2.  **`BeforeInstall`**: The `before_install.sh` script cleans the web directory (`/var/www/html`) to ensure a fresh installation.
3.  **`ApplicationStart`**: `start_server.sh` checks if the Apache2 service is already active and starts it if it is not.
4.  **`ValidateService`**: `validate_service.sh` uses `curl -f http://localhost/` to test if the website is running and accessible. The `-f` flag causes it to fail on HTTP server errors, which would trigger an automatic rollback of the deployment.
