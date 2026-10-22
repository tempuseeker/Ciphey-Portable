# Ciphey 5.14.0 便携版（Windows x64）

一个**免安装、可随身携带**的 [Ciphey](https://https://github.com/bee-san/Ciphey) 命令行版本：
输入看不懂的「密文」，它自己猜编码/加密方式并还原成明文。

整个文件夹放到哪里都能跑（包括中文路径、带空格的路径），不需要管理员权限，
**不会往系统 Python、注册表或 `%LOCALAPPDATA%` 写任何东西**。删掉文件夹即卸载。

由DeepSeek-V41-Flash辅助编译打包。

---

## 快速开始

打开命令提示符（cmd）或 PowerShell，进到本文件夹，然后：

```bat
:: 直接给密文（-g = 只输出结果，方便脚本使用）
Ciphey.cmd -g -t "aGVsbG8gbXkgbmFtZSBpcyBiZWU="
:: 结果: hello my name is bee

:: 从文件读
Ciphey.cmd -g -f cipher.txt

:: 从管道读
type cipher.txt | Ciphey.cmd -g

:: 看全部参数
Ciphey.cmd --help
```

> 不加 `-g` 时，Ciphey 解出候选明文后会问一句 `Possible plaintext: '...' (y/N):`，
> 让你确认它猜得对不对——这是它的正常交互，不是报错。

在 PowerShell 里调用要加 `.\`：`.\Ciphey.cmd -g -t "..."`。

---

## 目录结构

```
Ciphey-Portable\
├─ Ciphey.cmd            启动器（相对路径，可整体搬走）
├─ README.md             本文件
├─ config\               Ciphey 的配置目录（首次运行自动生成）
└─ python\               Python 3.8.10 嵌入式运行时 + 全部依赖
   ├─ python.exe
   ├─ python38._pth      模块搜索路径（相对路径）
   └─ Lib\site-packages\ ciphey / cipheycore / pywhat / rich / ...
```

## 组件版本

| 组件 | 版本 | 说明 |
|---|---|---|
| Ciphey | 5.14.0 | 项目最后一个发布版（2021 年，上游已归档） |
| cipheycore | 0.3.2 | 原生扩展（Rust），负责底层算法 |
| cipheydists | 0.3.35 | 词频/字典数据 |
| pywhat | 1.1.0 | 识别「这是什么」的辅助模块 |
| Python | 3.8.10 | CPython 官方 embeddable 包（amd64） |
| pip | 24.3.1 | 想额外装包可以用：`python\python.exe -m pip install ...` |

---

## 为什么要塞一个 Python 3.8 进去？

因为**新版本 Python 根本装不了 Ciphey**：

* `cipheycore` 是原生扩展，PyPI 上 **Windows 预编译轮子只到 cp38**（3.9 只剩 macOS/Linux，3.10+ 完全没有）。
  想用 3.9+ 就得自己装 Rust 工具链现场编译。
* Ciphey 把依赖钉死在 2021 年的老版本区间（`pyyaml<6`、`pylint<3`、`loguru<0.6`、`rich<11`），
  这些包在新 Python 上同样装不起来。

所以本便携版自带一个私有解释器，与系统 Python **完全隔离**，互不影响。

## 相对「pip install ciphey」做了哪些本地适配

1. **去掉 `.exe` 启动垫片。** pip 生成的 `Scripts\ciphey.exe` 会把安装时的绝对路径
   写进 exe 内部，文件夹一搬家就失效。本版改为 `Ciphey.cmd` → `python -m ciphey`，
   所有路径都用 `%~dp0` 相对解析。
2. **配置目录重定向**（`python\Lib\site-packages\ciphey\iface\_config.py` 内有一处注明
   为本地改动的 3 行代码）：Ciphey 原本固定把配置写到 `%LOCALAPPDATA%\ciphey`，
   现在优先读环境变量 `CIPHEY_CONFIG_DIR`，启动器把它指向本文件夹的 `config\`。
   不设该变量时行为与原版一致。
3. **强制 UTF-8**（启动器设置 `PYTHONUTF8=1`）：`pywhat` 读取自带 JSON 数据时没有指定
   编码，Python 3.8 在中文 Windows 上会按 GBK 解码并抛 `UnicodeDecodeError`。
   这是 Python 3.8 时代的已知兼容问题，不是本打包的 bug。

除以上三点外，包内容与 PyPI 上的官方发布一致（安装自清华镜像
`https://pypi.tuna.tsinghua.edu.cn/simple`）。

---

## 常见问题

**Q：第一次运行比较慢？**
首次运行要建 `config\`、加载词频数据，通常几秒到十几秒；之后会快一些。
Ciphey 本身会用搜索算法枚举多种解法，长文本可能需要更久。

**Q：能不能双击运行？**
双击 `Ciphey.cmd` 会进入交互式，直接把密文粘进去回车即可。

**Q：能不能放到 U 盘里？**
可以。整个文件夹拷走就行，不依赖注册表。注意目标是 64 位 Windows（运行时是 amd64）。

**Q：会不会改动我电脑的环境变量，或者依赖我装过的 Python？**
都不会。启动器用 `setlocal` 把 `CIPHEY_CONFIG_DIR` / `PYTHONUTF8` / `PYTHONIOENCODING`
限制在**单次进程内**，从不写系统或用户环境变量（不用 `setx`、不碰注册表）。
自带解释器还会忽略外部的 `PYTHONPATH` / `PYTHONHOME`，`sys.path` 只有包内那三条，
所以即使机器上没装 Python、或装的是别的版本，都不影响运行。

**Q：只读介质（光盘、只读共享）上能跑吗？**
能。启动器会先试写 `config\`：写不了会自动回退到 `%TEMP%\ciphey-portable`，
不会有额外输出。正常 U 盘/硬盘则始终把配置留在包内 `config\`，不留系统痕迹。

**Q：能不能装别的 Python 包进去？**
可以：`python\python.exe -m pip install <包名> -i https://pypi.tuna.tsinghua.edu.cn/simple`
（受限于 Python 3.8，只能装仍支持 3.8 的版本。）

**Q：上游还在维护吗？**
Ciphey 上游已归档，5.14.0 是最终版本。日常解谜够用，但新的编码/算法它不会跟进。

---

## 来源与许可

* Ciphey / cipheycore / cipheydists：见 `python\Lib\site-packages\*.dist-info` 内的元数据与各自许可证。
* Python 3.8.10：PSF License，见 `python\LICENSE.txt`。
* 其余第三方依赖各自遵循其许可证，均可在对应 `*.dist-info` 目录中查看。

本便携包只是把上述组件按可移植方式组装在一起，未修改其功能逻辑。
