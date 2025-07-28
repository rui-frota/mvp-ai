# MVP-AI

This project is a Ruby on Rails application that uses a locally running Llama model to process AI prompts.

## Prerequisites

- **Ruby** (recommended version: 3.1+)
- **Bundler**
- **Node.js** and **Yarn** (for assets)
- **SQLite**
- **Python 3** (to run Llama locally)
- **pip** (Python package manager)
- **git**

## Project Setup

### 1. Clone the repository

```sh
git clone https://github.com/your-user/mvp-ai.git
cd mvp-ai
```

### 2. Install Ruby dependencies

```sh
gem install bundler
bundle install
```

### 3. Install JavaScript dependencies

```sh
yarn install
```

### 4. Configure the database

Edit `config/database.yml` if needed.

Create and migrate the database:

```sh
rails db:create
rails db:migrate
```

### 5. Install and run Llama locally

#### a) Clone the Llama repository

```sh
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
```

#### b) Build Llama

```sh
make
```

#### c) Download a Llama model (example: 7B)

Follow the instructions in the [official repository](https://github.com/ggerganov/llama.cpp) to download a model. Example:

```sh
# Example download (adjust for your desired model)
wget https://huggingface.co/TheBloke/Llama-2-7B-GGUF/resolve/main/llama-2-7b.Q4_K_M.gguf -O models/llama-2-7b.gguf
```

#### d) Start the Llama server locally

```sh
./server -m models/llama-2-7b.gguf --port 8080
```

> **Note:** Make sure the service is running at `localhost:8080` or adjust your Rails project configuration accordingly.

### 6. Configure environment variables (if needed)

Create a `.env` file or set the necessary environment variables for Llama and database connection.

### 7. Start the Rails application

```sh
rails server
```

Visit [http://localhost:3000](http://localhost:3000) in your browser.

---

## Notes

- Make sure the Llama server is running before sending prompts from the application.
- For production, review security and performance settings.
- See the [llama.cpp documentation](https://github.com/ggerganov/llama.cpp) for more details about models and parameters.

---

## Useful commands

- Run tests:
  ```sh
  rails test
  ```
- Update dependencies:
  ```sh
  bundle update
  yarn upgrade
  ```

---

## Support

If you have questions, open an issue or contact the project maintainers.
