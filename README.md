# Repositorio de Dotfiles

Este repositorio contiene mis archivos de configuración personalizados (*dotfiles*) y una herramienta en Bash llamada **dot** que facilita la creación de enlaces simbólicos (*symlinks*) en tu sistema.

La herramienta **dot** te permite, de forma sencilla, crear symlinks en tu directorio home hacia los archivos o carpetas que tienes versionados en este repositorio. Puedes elegir enlazar todos los elementos o solo uno en concreto. Además, cuenta con una opción para forzar la sobrescritura de enlaces existentes.

## Contenido del repositorio

- **shell/**\
  Aquí se encuentran los archivos de configuración que deseas versionar.

- **.dot/**\
  Contiene la herramienta **dot** para crear los symlinks.

- Otros archivos (README, LICENSE, etc.)

## Instalación

1. **Clona el repositorio:**

   ```bash
   git clone https://github.com/tu-usuario/tu-repositorio.git ~/dotfiles
   ```

2. **Accede a la carpeta del repositorio:**

   ```bash
   cd ~/dotfiles
   ```

3. **(Opcional) Personaliza tus configuraciones dentro de la carpeta ****************`shell/`****************.**

## Uso de la herramienta **dot**

La herramienta **dot** se encuentra en la carpeta `.dot` y tiene la siguiente sintaxis:

```bash
./.dot/dot [--force] (--all | --file <ruta_relativa>)
```

### Opciones disponibles

- `--all`\
  Crea enlaces simbólicos para **todos** los elementos presentes en la carpeta de configuraciones (por defecto, la variable `REPO_DIR` está configurada en `$HOME/dotfiles/shell`).

- `--file <ruta_relativa>`\
  Crea el enlace simbólico **solo** para el archivo o carpeta especificado. La ruta es relativa al directorio de configuraciones (`REPO_DIR`).

- `--force`\
  Sobrescribe el destino si ya existe un archivo, directorio o enlace en el sistema. Por defecto, si el destino existe, se omite la creación del enlace.

### Ejemplos de uso

- **Enlazar todos los elementos:**

  ```bash
  ~/dotfiles/.dot/dot --all
  ```

- **Enlazar solo la configuración de Visual Studio Code (por ejemplo, ubicada en ****************`.config/Code`****************):**

  ```bash
  ~/dotfiles/.dot/dot --file .config/Code
  ```

- **Enlazar todos los elementos forzando la sobrescritura:**

  ```bash
  ~/dotfiles/.dot/dot --force --all
  ```

## Pruebas y seguridad

Para probar la herramienta sin afectar tu entorno real, puedes:

- Ejecutar el script en un directorio **HOME** temporal:

  ```bash
  mkdir -p /tmp/test-home
  export HOME=/tmp/test-home
  ~/dotfiles/.dot/dot --all
  ```

- Realizar una copia de respaldo de tus configuraciones actuales antes de ejecutar la herramienta:

  ```bash
  cp -r $HOME/.config $HOME/.config.backup
  ```

## Estructura del repositorio

La estructura actual del repositorio es la siguiente:

```
dotfiles/
├── shell/                # Carpeta con los archivos de configuración versionados
│   ├── kitty/            # Ejemplo de configuración de kitty
│   ├── nvim/             # Ejemplo de configuración de Neovim
│   └── ...               # Otras configuraciones
├── .dot/                 # Herramientas y scripts internos
│   └── dot               # Script principal para crear symlinks
├── README.md             # Este archivo
└── LICENSE               # Licencia del proyecto
```

## Contribuciones

Si deseas mejorar la herramienta o agregar nuevas funcionalidades, siéntete libre de hacer *fork* y enviar *pull requests*.\
Antes de contribuir, por favor revisa las [Directrices de Contribución](CONTRIBUTING.md) (si dispones de ellas).

## Licencia

Este proyecto se distribuye bajo la [Licencia MIT](LICENSE).

## Contacto

Para cualquier duda o sugerencia, puedes [abrir un issue](https://github.com/tu-usuario/tu-repositorio/issues) en GitHub o contactarme a través de [tu correo electrónico](mailto\:tu.email@ejemplo.com).


