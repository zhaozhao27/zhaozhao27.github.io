+++
title = "使用 Rust 为mipsel 平台交叉编译"
date = 2024-11-02T18:35:09-07:00
type = "post"
description = "使用 Rust 为mipsel 平台交叉编译，来适配uclibc 库"
[taxonomies]
tags = ["Rust", "Mips", "rust-no-std"]

+++

最近在使用mipsel的平台进行应用开发，于是心血来潮要在mipsel平台上运行一个Rust的工程

目前Rust在官方不再对mipsel-unknown-linux-uclibc 专门的支持，如果我们想为这个平台编译Rust程序，一种方法是在Cargo 中加入 `-Zbuild-std`指令，这样便可以手动编译对应目标的Rust的标准库，例如 `cargo build -Zbuild-std --target mipsel-unknown-linux-uclibc --release`，但是每次都这样编译的话，还是有些许麻烦，这里就记录一下为 `mipsel-unknown-linux-uclibc`这个目标制作工具链的过程



### 准备工作

首先是环境配置 ，我们需要 先安装官方的Rust工具链，这里就不再进行详细介绍 ，如果有网络问题导致安装失败 ，推荐搜索关键词 ，           "Rustup 安装 字节源"

#### 下载 [rust-lang](https://github.com/rust-lang/rust) 源码 

```bash
git clone https://github.com/rust-lang/rust.git` 
```
然后基于 发布版本的tag 创建分支

```bash
git checkout -b 1.82.0 1.82.0 --recurse-submodules -f
```

 这里建议选择 选择 最近发布 的新版本的 tag ,因为rust-lang 的编译需要用到LLVM, 如果tag版本比较旧的话，我们拉取对应版本的 LLVM 编译器的预构建版本可能会失败 ，我们还需要再编译对应版本的LLVM , 而LLVM 编译相当耗时 

### 编译rust-lang

##### 修改配置文件 

进入源代码目录 ，将 config.toml.example 复制一份为 config.toml 文件，修改 config.toml 文件

```bash
cd rust && cp config.toml.example config.toml && vim config.toml
```

这是我的配置 , 按需修改 ，`download-ci-llvm`为true 的话就是使用 预编译的 llvm ，可以节省 整体 编译时间 ，以及  `cargo、rustc rustfmt` 的配置也是同理

我这里安装路径是在家目录下的.local中 ,  对于 家目录 下的路径 `~`可能不会生效，建议使用绝对目录 

```toml

change-id = 129295
[llvm]

download-ci-llvm = true

[build]
build = "x86_64-unknown-linux-gnu"
target = ["mipsel-unknown-linux-uclibc",
	  "x86_64-unknown-linux-gnu"]
cargo = "/home/zhaozhao/.cargo/bin/cargo"
rustc = "/home/zhaozhao/.cargo/bin/rustc"
rustfmt = "/home/zhaozhao/.cargo/bin/rustfmt"
extended = true

tools = [
    "cargo",
    "c2rust",
    "rls",
    "clippy",
    "rustdoc",
    "rustfmt",
    "rust-analyzer",
    "rust-analyzer-proc-macro-srv",
    "analysis",
    "src",
    "rust-demangler",  # if profiler = true
]

[install]

# Where to install the generated toolchain. Must be an absolute path.
prefix = "/home/zhaozhao/.local"
sysconfdir = "etc"
docdir = "share/doc/rust"
bindir = "bin"
libdir = "lib"
mandir = "share/man"
datadir = "share"
[rust]

[target.x86_64-unknown-linux-gnu]

[target.mipsel-unknown-linux-uclibc]
    cc = "/opt/mips-gcc540-glibc222-64bit-r3.3.0/bin/mips-linux-uclibc-gnu-gcc"
    cxx = "/opt/mips-gcc540-glibc222-64bit-r3.3.0/bin/mips-linux-uclibc-gnu-c++"
    ar = "/opt/mips-gcc540-glibc222-64bit-r3.3.0/bin/mips-linux-uclibc-gnu-ar"
    linker = "/opt/mips-gcc540-glibc222-64bit-r3.3.0/bin/mips-linux-uclibc-gnu-gcc"

[dist]

```

##### 配置环境变量

路径替换成自己的工具链目录，不配置的话编译可能失败

```bash
export CC_mipsel_unknown_linux_uclibc=/opt/mips-gcc540-glibc222-64bit-r3.3.0/bin/mips-linux-uclibc-gnu-gcc
export STAGING_DIR=/opt/mips-gcc540-glibc222-64bit-r3.3.0/
```



##### 编译并安装 

```bash
./x.py build && ./x.py install 
```

将工具链链接到rustup, 名字可以自己取

```bash
rustup toolchain link mipsel-unknown-linux-uclibc ~/.local
```

然后 就可以看到我们的工具链啦 

```bash
rustup show
```



到此就可以直接编译 mipsel 的uclibc 平台的目标啦 ~ 

附一个demo 工程 [sample_mips](https://github.com/zhaozhao27/sample_mips)

###### **参考文章**

 [Cross Compile Rust For OpenWRT by 前尘逐梦](https://qianchenzhumeng.github.io/posts/cross-compile-rust-for-openwrt/)
