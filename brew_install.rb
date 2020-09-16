＃！/ bin / bash
设置-u

＃首先检查操作系统是否为Linux。
如果[[“ $（uname）” =“ Linux”]]; 然后
  HOMEBREW_ON_LINUX = 1
科幻

＃在macOS上，此脚本仅安装到/ usr / local。
＃在Linux上，如果您具有sudo访问权限，它将安装到/home/linuxbrew/.linuxbrew
＃和〜/ .linuxbrew否则。
＃安装在其他地方（不受支持）
＃您可以解压缩https://github.com/Homebrew/brew/tarball/master
＃您喜欢的任何地方。
如果[[-z“ $ {HOMEBREW_ON_LINUX-}”]]; 然后
  HOMEBREW_PREFIX =“ / usr / local”
  HOMEBREW_REPOSITORY =“ / usr / local / Homebrew”
  HOMEBREW_CACHE =“ $ {HOME} / Library / Caches / Homebrew”

  STAT =“ stat -f”
  CHOWN =“ / usr / sbin / chown”
  CHGRP =“ / usr / bin / chgrp”
  GROUP =“ admin”
  TOUCH =“ / usr / bin / touch”
其他
  HOMEBREW_PREFIX_DEFAULT =“ / home / linuxbrew / .linuxbrew”
  HOMEBREW_CACHE =“ $ {HOME} /。cache / Homebrew”

  STAT =“ stat --printf”
  CHOWN =“ / bin / chown”
  CHGRP =“ / bin / chgrp”
  GROUP =“ $（id -gn）”
  TOUCH =“ / bin / touch”
科幻
BREW_REPO =“ https://github.com/Homebrew/brew”

＃TODO：发布新的macOS时的凹凸版本
MACOS_LATEST_SUPPORTED =“ 10.15”
＃TODO：发布新的macOS时的凹凸版本
MACOS_OLDEST_SUPPORTED =“ 10.13”

＃对于Linux上的Homebrew
REQUIRED_RUBY_VERSION = 2.6＃https://github.com/Homebrew/brew/pull/6556
REQUIRED_GLIBC_VERSION = 2.13＃https://docs.brew.sh/Homebrew-on-Linux#requirements

＃安装期间无分析
汇出HOMEBREW_NO_ANALYTICS_THIS_RUN = 1
汇出HOMEBREW_NO_ANALYTICS_MESSAGE_OUTPUT = 1

＃个字符串格式化程序
如果[[-t 1]]; 然后
  tty_escape（）{printf“ \ 033 [％sm”“ $ 1”; }
其他
  tty_escape（）{：; }
科幻
tty_mkbold（）{tty_escape“ 1; $ 1”; }
tty_underline =“ $（tty_escape” 4; 39“）”
tty_blue =“ $（tty_mkbold 34）”
tty_red =“ $（tty_mkbold 31）”
tty_bold =“ $（tty_mkbold 39）”
tty_reset =“ $（tty_escape 0）”

have_sudo_access（）{
  本地-a参数
  如果[[-n“ $ {SUDO_ASKPASS-}”]]; 然后
    args =（“-A”）
  科幻

  如果[[-z“ $ {HAVE_SUDO_ACCESS-}”]]; 然后
    如果[[-n“ $ {args [*]-}”]]]; 然后
      / usr / bin / sudo“ $ {args [@]}” -l mkdir＆> / dev / null
    其他
      / usr / bin / sudo -l mkdir＆> / dev / null
    科幻
    HAVE_SUDO_ACCESS =“ $？”
  科幻

  如果[[-z“ $ {HOMEBREW_ON_LINUX-}”]] && [[“ $ HAVE_SUDO_ACCESS” -ne 0]]; 然后
    中止“需要在macOS上进行sudo访问（例如，用户$ USER为管理员）！”
  科幻

  返回“ $ HAVE_SUDO_ACCESS”
}

shell_join（）{
  本地arg
  printf“％s”“ $ 1”
  转移
  对于“ $ @”中的arg；做
    printf“”
    printf“％s”“ $ {arg // / \}”
  做完了
}

chomp（）{
  printf“％s”“ $ {1 /” $'\ n'“ /}”
}

ohai（）{
  printf“ $ {tty_blue} ==> $ {tty_bold}％s $ {tty_reset} \ n”“ $（shell_join” $ @“）”
}

warn（）{
  printf“ $ {tty_red}警告$ {tty_reset}：％s \ n”“ $（chomp” $ 1“）”
}

abort（）{
  printf“％s \ n”“ $ 1”
  1号出口
}

执行（） {
  如果！“ $ @”；然后
    中止“ $（printf”在％s期间失败“” $（shell_join“ $ @”）“）”
  科幻
}

execute_sudo（）{
  本地-a args =（“ $ @”）
  如果[[-n“ $ {SUDO_ASKPASS-}”]]; 然后
    args =（“-A”“ $ {args [@]}”）
  科幻
  如果有have_sudo_access; 然后
    ohai“ / usr / bin / sudo”“ $ {args [@]}”
    执行“ / usr / bin / sudo”“ $ {args [@]}”
  其他
    ohai“ $ {args [@]}”
    执行“ $ {args [@]}”
  科幻
}

getc（）{
  本地save_state
  save_state = $（/ bin / stty -g）
  / bin / stty原始-echo
  IFS =读取-r -n 1 -d''“ $ @”
  / bin / stty“ $ save_state”
}

wait_for_user（）{
  本地c
  回声
  回声“按返回继续或任何其他键中止”
  getc c
  ＃我们测试\ r和\ n，因为有些东西代替了\ r
  如果！[[“ $ c” == $'\ r'|| “ $ c” == $'\ n']]; 然后
    1号出口
  科幻
}

主要次要（） {
  回声“ $ {1 %%。*}。$（x =” $ {1＃*。}“;回声” $ {x %%。*}“）”
}

如果[[-z“ $ {HOMEBREW_ON_LINUX-}”]]; 然后
  macos_version =“ $（major_minor” $（/ usr / bin / sw_vers -productVersion）“）”
科幻

version_gt（）{
  [[“” $ {1％。*}“ -gt” $ {2％。*}“]] || [[“” $ {1％。*}“ -eq” $ {2％。*}“ &&” $ {1＃*。}“ -gt” $ {2＃*。}“]]]
}
version_ge（）{
  [[“” $ {1％。*}“ -gt” $ {2％。*}“]] || [[“” $ {1％。*}“ -eq” $ {2％。*}“ &&” $ {1＃*。}“ -ge” $ {2＃*。}“]]]
}
version_lt（）{
  [[“” $ {1％。*}“ -lt” $ {2％。*}“]] || [[“” $ {1％。*}“ -eq” $ {2％。*}“ &&” $ {1＃*。}“ -lt” $ {2＃*。}“]]]
}

should_install_command_line_tools（）{
  如果[[-n“ $ {HOMEBREW_ON_LINUX-}”]]; 然后
    返回1
  科幻

  如果version_gt“ $ macos_version”“ 10.13”; 然后
    ！[[-e“ / Library / Developer / CommandLineTools / usr / bin / git”]]
  其他
    ！[[-e“ / Library / Developer / CommandLineTools / usr / bin / git”]] ||
      ！[[-e“ /usr/include/iconv.h”]]
  科幻
}

get_permission（）{
  $ STAT“％A”“ $ 1”
}

user_only_chmod（）{
  [[-d“ $ 1”]] && [[“ $（get_permission” $ 1“）”！=“” 755“]]
}

exist_but_not_writable（）{
  [[-e“ $ 1”]] &&！[[-r“ $ 1” && -w“ $ 1” && -x“ $ 1”]]
}

get_owner（）{
  $ STAT“％u”“ $ 1”
}

file_not_owned（）{
  [[“ $（get_owner” $ 1“）”！=“” $（id -u）“]]
}

get_group（）{
  $ STAT“％g”“ $ 1”
}

file_not_grpowned（）{
  [[“ $（id -G” $ USER“）”！= *“ $（get_group” $ 1“）” *]]
}

＃请与Homebrew / brew存储库中“ Library / Homebrew / utils / ruby​​.sh”中的“ test_ruby（）”同步。
test_ruby（）{
  如果[[！-x $ 1]]
  然后
    返回1
  科幻

  “ $ 1” --enable-frozen-string-literal --disable = gems，did_you_mean，rubyopt -rrubygems -e \
    “如果Gem :: Version.new（RUBY_VERSION.to_s.dup）.to_s.split（'。'）。first（2），则中止！= \
              Gem :: Version.new（'$ REQUIRED_RUBY_VERSION'）。to_s.split（'。'）。first（2）“ 2> / dev / null
}

no_usable_ruby（）{
  本地ruby_exec
  IFS = $'\ n'＃仅在新行上进行单词拆分
  为$（其中-a ruby​​）中的ruby_exec; 做
    如果test_ruby“ $ ruby​​_exec”; 然后
      返回1
    科幻
  做完了
  IFS = $'\ t \ n'＃将IFS恢复为默认值
  返回0
}

outdated_glibc（）{
  本地glibc_version
  glibc_version = $（ldd --version | head -n1 | grep -o'[0-9。] * $'| grep -o'^ [0-9] \ + \。[0-9] \ +'）
  version_lt“ $ glibc_version”“ $ REQUIRED_GLIBC_VERSION”
}

如果[[-n“ $ {HOMEBREW_ON_LINUX-}”]] && no_usable_ruby && outdated_glibc
然后
    中止“ $（cat <<-EOFABORT
	自制软件需要在系统上找不到的Ruby $ REQUIRED_RUBY_VERSION。
	自制的便携式Ruby需要Glibc版本$ REQUIRED_GLIBC_VERSION或更高版本，
	您的Glibc版本太旧了。
	参见$ {tty_underline} https://docs.brew.sh/Homebrew-on-Linux#requirements$ {tty_reset}
	安装Ruby $ REQUIRED_RUBY_VERSION并将其位置添加到您的PATH中。
	EOFABORT
    ）”
科幻

＃并非总是设置USER，因此为安装程序和子流程提供一个后备。
如果[[-z“ $ {USER-}”]]; 然后
  USER =“ $（chomp” $（id -un）“）”
  汇出USER
科幻

＃退出前使sudo时间戳无效（如果之前未激活）。
如果！/ usr / bin / sudo -n -v 2> / dev / null; 然后
  陷阱'/ usr / bin / sudo -k'退出
科幻

＃如果`pwd`不存在，以后事情可能会失败。
＃同样sudo也会无故打印警告消息
cd“ / usr” || 1号出口

################################################ #####################脚本
如果！命令-v git> / dev / null; 然后
    中止“ $（cat << EOABORT
您必须在安装Homebrew之前安装Git。看到：
  $ {tty_underline} https://docs.brew.sh/Installation$ {tty_reset}
欧宝
）”
科幻

如果！命令-v curl> / dev / null; 然后
    中止“ $（cat << EOABORT
在安装Homebrew之前，您必须安装cURL。看到：
  $ {tty_underline} https://docs.brew.sh/Installation$ {tty_reset}
欧宝
）”
科幻

如果[[-z“ $ {HOMEBREW_ON_LINUX-}”]]; 然后
 have_sudo_access
其他
  如果[[-n“ $ {CI-}”]] || [[-w“ $ HOMEBREW_PREFIX_DEFAULT”]] || [[-w“ / home / linuxbrew”]] || [[-w“ / home”]]; 然后
    HOMEBREW_PREFIX =“ $ HOMEBREW_PREFIX_DEFAULT”
  其他
    陷阱出口SIGINT
    如果[[$（/ usr / bin / sudo -n -l mkdir 2>＆1）！= *“ mkdir” *]]；然后
      ohai“选择Homebrew安装目录”
      echo“-$ {tty_bold}输入密码$ {tty_reset}以安装到$ {tty_underline} $ {HOMEBREW_PREFIX_DEFAULT} $ {tty_reset}（$ {tty_bold} recommended $ {tty_reset}）”
      echo“-$ {tty_bold}按Control-D $ {tty_reset}以安装到$ {tty_underline} $ HOME / .linuxbrew $ {tty_reset}”
      echo“-$ {tty_bold}按Control-C $ {tty_reset}取消安装”
    科幻
    如果有have_sudo_access; 然后
      HOMEBREW_PREFIX =“ $ HOMEBREW_PREFIX_DEFAULT”
    其他
      HOMEBREW_PREFIX =“ $ HOME / .linuxbrew”
    科幻
    陷阱-SIGINT
  科幻
  HOMEBREW_REPOSITORY =“ $ {HOMEBREW_PREFIX} / Homebrew”
科幻

如果[[“ $ UID” ==“ 0”]]; 然后
  中止“不要以超级用户身份运行此文件！”
elif [[-d“ $ HOMEBREW_PREFIX” &&！-x“ $ HOMEBREW_PREFIX”]]; 然后
  中止“ $（cat << EOABORT
Homebrew前缀$ {HOMEBREW_PREFIX}存在，但不可搜索。如果这是
并非故意的，请恢复默认权限，然后尝试运行
再次安装：
    sudo chmod 775 $ {HOMEBREW_PREFIX}
欧宝
）”
科幻

如果[[-z“ $ {HOMEBREW_ON_LINUX-}”]]; 然后
  如果version_lt“ $ macos_version”“ 10.7”; 然后
    中止“ $（cat << EOABORT
您的Mac OS X版本太旧。看到：
  $ {tty_underline} https://github.com/mistydemeo/tigerbrew$ {tty_reset}
欧宝
）”
  elif version_lt“ $ macos_version”“ 10.10”; 然后
    中止“您的OS X版本太旧”
  elif version_gt“ $ macos_version”“ $ MACOS_LATEST_SUPPORTED” || \
    version_lt“ $ macos_version”“ $ MACOS_OLDEST_SUPPORTED”; 然后
    who =“我们”
    what =“”
    如果version_gt“ $ macos_version”“ $ MACOS_LATEST_SUPPORTED”; 然后
      what =“预发行版本”
    其他
      who + =“（和Apple）”
      what =“旧版本”
    科幻
    ohai“您正在使用macOS $ {macos_version}。”
    ohai“ $ {who}不为此$ {what}提供支持。”

    echo“ $（cat << EOS
此安装可能不会成功。
安装后，您将遇到某些公式的构建失败。
请创建拉取请求，而不是在Homebrew的GitHub上寻求帮助，
话语，Twitter或IRC。您有责任解决您遇到的任何问题
运行$ {what}时的体验。
EOS
）
”
  科幻
科幻

ohai“此脚本将安装：”
回声“ $ {HOMEBREW_PREFIX} / bin / brew”
回声“ $ {HOMEBREW_PREFIX} / share / doc / homebrew”
回声“ $ {HOMEBREW_PREFIX} /share/man/man1/brew.1”
回声“ $ {HOMEBREW_PREFIX} / share / zsh / site-functions / _brew”
回声“ $ {HOMEBREW_PREFIX} /etc/bash_completion.d/brew”
回显“ $ {HOMEBREW_REPOSITORY}”

＃与之保持相对同步
＃https://github.com/Homebrew/brew/blob/master/Library/Homebrew/keg.rb
目录=（bin等包括lib sbin share opt var
             构架
             etc / bash_completion.d lib / pkgconfig
             共享/本地共享/文档共享/信息共享/语言环境共享/人
             共享/ man / man1共享/ man / man2共享/ man / man3共享/ man / man4
             共享/ man / man5共享/ man / man6共享/ man / man7共享/ man / man8
             var / log var / homebrew var / homebrew / linked
             bin / brew）
group_chmods =（）
对于“ $ {目录[@]}”中的目录；做
  如果exist_but_not_writable“ $ {HOMEBREW_PREFIX} / $ {dir}”；然后
    group_chmods + =（“ $ {HOMEBREW_PREFIX} / $ {dir}”）
  科幻
做完了

＃zsh拒绝从这些目录读取（如果组可写）
目录=（共享/ zsh共享/ zsh /站点功能）
zsh_dirs =（）
对于“ $ {目录[@]}”中的目录；做
  zsh_dirs + =（“ $ {HOMEBREW_PREFIX} / $ {dir}”）
做完了

目录=（bin等包括lib sbin share var opt
             共享/ zsh共享/ zsh /站点功能
             var / homebrew var / homebrew / linked
             酒窖酒窖自制酒框架）
mkdirs =（）
对于“ $ {目录[@]}”中的目录；做
  如果！[[-d“ $ {HOMEBREW_PREFIX} / $ {dir}”]]；然后
    mkdirs + =（“ $ {HOMEBREW_PREFIX} / $ {dir}”）
  科幻
做完了

user_chmods =（）
如果[[“ $ {＃zsh_dirs [@]}” -gt 0]]; 然后
  对于“ $ {zsh_dirs [@]}”中的目录；做
    如果user_only_chmod“ $ {dir}”; 然后
      user_chmods + =（“ $ {dir}”）
    科幻
  做完了
科幻

chmods =（）
如果[[“ $ {＃group_chmods [@]}” -gt 0]]; 然后
  chmods + =（“ $ {group_chmods [@]}”）
科幻
如果[[“ $ {＃user_chmods [@]}” -gt 0]]; 然后
  chmods + =（“ $ {user_chmods [@]}”）
科幻

chowns =（）
chgrps =（）
如果[[“ $ {＃chmods [@]}” -gt 0]]; 然后
  对于“ $ {chmods [@]}”中的目录；做
    如果file_not_owned“ $ {dir}”; 然后
      chowns + =（“” $ {dir}“）
    科幻
    如果file_not_grpowned为“ $ {dir}”；然后
      chgrps + =（“” $ {dir}“）
    科幻
  做完了
科幻

如果[[“ $ {＃group_chmods [@]}” -gt 0]]; 然后
  ohai“将以下现有目录设置为可写组：”
  printf“％s \ n”“ $ {group_chmods [@]}”
科幻
如果[[“ $ {＃user_chmods [@]}” -gt 0]]; 然后
  ohai“以下现有目录将只能由用户写入：”
  printf“％s \ n”“ $ {user_chmods [@]}”
科幻
如果[[“ $ {＃chowns [@]}” -gt 0]]; 然后
  ohai“以下现有目录的所有者将设置为$ {tty_underline} $ {USER} $ {tty_reset}：”
  printf“％s \ n”“ $ {chowns [@]}”
科幻
如果[[“ $ {＃chgrps [@]}” -gt 0]]; 然后
  ohai“以下现有目录将其组设置为$ {tty_underline} $ {GROUP} $ {tty_reset}：”
  printf“％s \ n”“ $ {chgrps [@]}”
科幻
如果[[“ $ {＃mkdirs [@]}” -gt 0]]; 然后
  ohai“将创建以下新目录：”
  printf“％s \ n”“ $ {mkdirs [@]}”
科幻

如果should_install_command_line_tools; 然后
  ohai“将安装Xcode命令行工具。”
科幻

如果[[-t 0 && -z“ $ {CI-}”]]; 然后
  wait_for_user
科幻

如果[[-d“ $ {HOMEBREW_PREFIX}”]]; 然后
  如果[[“ $ {＃chmods [@]}” -gt 0]]; 然后
    execute_sudo“ / bin / chmod”“ u + rwx”“ $ {chmods [@]}”
  科幻
  如果[[“ $ {＃group_chmods [@]}” -gt 0]]; 然后
    execute_sudo“ / bin / chmod”“ g + rwx”“ $ {group_chmods [@]}”
  科幻
  如果[[“ $ {＃user_chmods [@]}” -gt 0]]; 然后
    execute_sudo“ / bin / chmod”“ 755”“ $ {user_chmods [@]}”
  科幻
  如果[[“ $ {＃chowns [@]}” -gt 0]]; 然后
    execute_sudo“ $ CHOWN”“ $ USER”“ $ {chowns [@]}”
  科幻
  如果[[“ $ {＃chgrps [@]}” -gt 0]]; 然后
    execute_sudo“ $ CHGRP”“ $ GROUP”“ $ {chgrps [@]}”
  科幻
其他
  execute_sudo“ / bin / mkdir”“ -p”“ $ {HOMEBREW_PREFIX}”
  如果[[-z“ $ {HOMEBREW_ON_LINUX-}”]]; 然后
    execute_sudo“ $ CHOWN”“ root：wheel”“ $ {HOMEBREW_PREFIX}”
  其他
    execute_sudo“ $ CHOWN”“ $ USER：$ GROUP”“ $ {HOMEBREW_PREFIX}”
  科幻
科幻

如果[[“ $ {＃mkdirs [@]}” -gt 0]]; 然后
  execute_sudo“ / bin / mkdir”“ -p”“ $ {mkdirs [@]}”
  execute_sudo“ / bin / chmod”“ g + rwx”“ $ {mkdirs [@]}”
  execute_sudo“ $ CHOWN”“ $ USER”“ $ {mkdirs [@]}”
  execute_sudo“ $ CHGRP”“ $ GROUP”“ $ {mkdirs [@]}”
科幻

如果！[[-d“ $ {HOMEBREW_CACHE}”]]; 然后
  如果[[-z“ $ {HOMEBREW_ON_LINUX-}”]]; 然后
    execute_sudo“ / bin / mkdir”“ -p”“ $ {HOMEBREW_CACHE}”
  其他
    执行“ / bin / mkdir”“ -p”“ $ {HOMEBREW_CACHE}”
  科幻
科幻
如果exist_but_not_writable“ $ {HOMEBREW_CACHE}”; 然后
  execute_sudo“ / bin / chmod”“ g + rwx”“ $ {HOMEBREW_CACHE}”
科幻
如果file_not_owned为“ $ {HOMEBREW_CACHE}”；然后
  execute_sudo“ $ CHOWN”“ $ USER”“ $ {HOMEBREW_CACHE}”
科幻
如果file_not_grpowned为“ $ {HOMEBREW_CACHE}”；然后
  execute_sudo“ $ CHGRP”“ $ GROUP”“ $ {HOMEBREW_CACHE}”
科幻
如果[[-d“ $ {HOMEBREW_CACHE}”]]; 然后
  执行“ $ TOUCH”“ $ {HOMEBREW_CACHE} /。cleaned”
科幻

if should_install_command_line_tools && version_ge“ $ macos_version”“ 10.13”; 然后
  ohai“在线搜索命令行工具”
  ＃此临时文件提示'softwareupdate'实用程序列出命令行工具
  clt_placeholder =“ / tmp / .com.apple.dt.CommandLineTools.installondemand.in-progress”
  execute_sudo“ $ TOUCH”“ $ clt_placeholder”

  clt_label_command =“ / usr / sbin / softwareupdate -l |
                      grep -B 1 -E'命令行工具'|
                      awk -F'*''/ ^ * \\ * / {print \ $ 2}'|
                      sed -e's / ^ *标签：//'-e's / ^ * //'|
                      排序-V |
                      尾巴-n1“
  clt_label =“ $（chomp” $（/ bin / bash -c“ $ clt_label_command”）“）”

  如果[[-n“ $ clt_label”]]; 然后
    ohai“正在安装$ clt_label”
    execute_sudo“ / usr / sbin / softwareupdate”“ -i”“ $ clt_label”
    execute_sudo“ / bin / rm”“ -f”“ $ clt_placeholder”
    execute_sudo“ / usr / bin / xcode-select”“ --switch”“ / Library / Developer / CommandLineTools”
  科幻
科幻

＃无头安装可能失败，因此回退到原始的'xcode-select'方法
如果should_install_command_line_tools && test -t 0; 然后
  ohai“安装命令行工具（期望GUI弹出窗口）：”
  execute_sudo“ / usr / bin / xcode-select”“-安装”
  echo“安装完成后，按任意键。”
  getc
  execute_sudo“ / usr / bin / xcode-select”“ --switch”“ / Library / Developer / CommandLineTools”
科幻

如果[[-z“ $ {HOMEBREW_ON_LINUX-}”]] &&！输出=“ $（/ usr / bin / xcrun clang 2>＆1）” && [[“” $ output“ == *”许可证“ *]]; 然后
  中止“ $（cat << EOABORT
您尚未同意Xcode许可证。
在再次运行安装程序之前，请先打开
Xcode.app或正在运行：
    须藤xcodebuild -license
欧宝
）”
科幻

ohai“正在下载和安装Homebrew ...”
（
  cd“ $ {HOMEBREW_REPOSITORY}”> / dev / null || 返回

  ＃我们分四个步骤进行操作，以避免重新安装时出现合并错误
  执行“ git”“ init”“-q”

  ＃如果在全局配置中定义了远程，则“ git remote add”将失败
  执行“ git”“ config”“ remote.origin.url”“ $ {BREW_REPO}”
  执行“ git”“ config”“ remote.origin.fetch”“ + refs / heads / *：refs / remotes / origin / *”

  ＃确保我们在结帐时不排除行尾
  执行“ git”“ config”“ core.autocrlf”“ false”

  执行“ git”“获取”“源”“ --force”
  执行“ git”“获取”“源”“ --tags”“-force”

  执行“ git”“重置”“ --hard”“源/主”

  执行“ ln”“ -sf”“ $ {HOMEBREW_REPOSITORY} / bin / brew”“ $ {HOMEBREW_PREFIX} / bin / brew”

  执行“ $ {HOMEBREW_PREFIX} / bin / brew”“更新”“ --force”
）|| 1号出口

如果[[“：$ {PATH}：”！= *“：$ {HOMEBREW_PREFIX} / bin：” *]]; 然后
  警告“ $ {HOMEBREW_PREFIX} / bin不在您的PATH中。”
科幻

ohai“安装成功！”
回声

＃使用外壳的声音铃。
如果[[-t 1]]; 然后
  printf“ \ a”
科幻

＃使用额外的换行符和粗体，以免遗漏。
ohai“ Homebrew已启用匿名聚合公式和容器分析。”
echo“ $（cat << EOS
$ {tty_bold}在此处阅读分析文档（以及如何退出）：
  $ {tty_underline} https://docs.brew.sh/Analytics$ {tty_reset}
尚未发送任何分析数据（或将在此\`install \`运行期间发送）。
EOS
）
”

ohai“自制软件完全由无偿志愿者经营。请考虑捐赠：”
echo“ $（cat << EOS
  $ {tty_underline} https://github.com/Homebrew/brew#donations$ {tty_reset}
EOS
）
”

（
  cd“ $ {HOMEBREW_REPOSITORY}”> / dev / null || 返回
  执行“ git”“ config”“-全部替换”“ homebrew.analyticsmessage”“ true”
  执行“ git”“ config”“-全部替换”“ homebrew.caskanalyticsmessage”“ true”
）|| 1号出口

ohai“下一步：”
回显“-运行“ brew help”以开始使用”
echo“-进一步的文档：”
回声“ $ {tty_underline} https：//docs.brew.sh$ {tty_reset}”

如果[[-n“ $ {HOMEBREW_ON_LINUX-}”]]; 然后
  案例“ $ SHELL”在
    * /重击*）
      如果[[-r“ $ HOME / .bash_profile”]]; 然后
        shell_profile =“ $ HOME / .bash_profile”
      其他
        shell_profile =“ $ HOME / .profile”
      科幻
      ;;
    * / zsh *）
      shell_profile =“ $ HOME / .zprofile”
      ;;
    *）
      shell_profile =“ $ HOME / .profile”
      ;;
  埃萨克

  回声“-如果您具有sudo访问权限，请安装Homebrew依赖项：”

  如果[[$（command -v apt-get）]]; 然后
    回声“ sudo apt-get install build-essential”
  elif [[$（command -v yum）]]; 然后
    echo“ sudo yum groupinstall'开发工具'”
  elif [[$（command -v pacman）]]; 然后
    回声“ sudo pacman -S base-devel”
  elif [[$（command -v apk）]]; 然后
    回声“ sudo apk添加构建基础”
  科幻

  猫<< EOS
    有关更多信息，请参见$ {tty_underline} https://docs.brew.sh/linux$ {tty_reset}
-在$ {tty_underline} $ {shell_profile} $ {tty_reset}中的$ {tty_bold} PATH $ {tty_reset}中添加Homebrew：
    回声'eval \ $（$ {HOMEBREW_PREFIX} / bin / brew shellenv）'>> $ {shell_profile}
    评估\ $（$ {HOMEBREW_PREFIX} / bin / brew shellenv）
-我们建议您安装GCC：
    brew安装gcc

EOS
科幻