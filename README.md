# zserve

`zserve` is a lightweight, high-performance static file server written in Zig. It's designed to be simple, fast, and easy to use for serving static websites, single-page applications, or any directory of files over HTTP.

## Features

- **Fast & Efficient:** Built with Zig for optimal performance and low resource usage.
- **Simple to Use:** Serve any directory with a single command.
- **Configurable:** Easily change the host and port.
- **Cross-Platform:** Runs on any platform supported by the Zig compiler.

## Getting Started

### Prerequisites

You need to have the Zig compiler installed on your system. You can find installation instructions on the official [Zig website](https://ziglang.org/learn/getting-started/).

### Building

1.  Clone the repository:
    ```sh
    git clone https://github.com/your-username/zserve.git
    cd zserve
    ```

2.  Build the project:
    ```sh
    zig build
    ```
    This will create an executable in the `zig-out/bin` directory.

### Running the Server

You can run the server directly using `zig build run` or by executing the compiled binary. The server requires you to specify the folder you want to serve.

```sh
zig build run -- -f ./path/to/your/folder
```

Or run the compiled binary:

```sh
./zig-out/bin/zserve -f ./path/to/your/folder
```

The server will start, and you can access your files in a web browser, by default at `http://127.0.0.1:8080`.

## Command-Line Options

You can customize the server's behavior using the following command-line flags:

-   `-f <path>`: (Required) The path to the directory you want to serve files from.
-   `-h <host>`: (Optional) The host address to bind the server to. Defaults to `127.0.0.1`.
-   `-p <port>`: (Optional) The port for the server to listen on. Defaults to `8080`.

### Example

To serve files from a directory named `my-website` on port `3000`:

```sh
zig build run -- -f ./my-website -p 3000
```

Now you can access your site at `http://127.0.0.1:3000`.

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue on GitHub.

## License

This project is licensed under the MIT License.
