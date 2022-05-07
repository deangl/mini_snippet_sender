# Mini snippet sender
用AHK写的snippet发送器
## 用途
根据当前窗口的不同，生成snippets列表。输入列表中的key，能向窗口发送snippet。
## 用法
* 通过`conf.json`文件设定快捷键，`#`代表windows键，`!`代表alt键，`^`代表ctrl键, `+`代表shift键。格式看例子。
* 通过`snippets.json`文件设定snippets。见下面说明：

``` json
  {
    "- 记事本":{ //窗口名，可以用window spy查到
	"jys": {"name":"静夜思","string":"静夜思`n床前明月光，疑是地上霜。`n举头望明月，低头思故乡。"}, //分别为key，显示名，待发送snippet
	"hlo": {"name":"你好呀","string":"我说，<@>，你还好吗？"} //<@>是光标位置的占位符
    },
    "any":{ //any代表对任何窗口都生效
	"lazy":{"name":"懒","string":"懒就用snippets"},
	"hlo":{"name":"打招呼","string":"Hi,Snippets"} //在多个规则都匹配上了时候，那么重复的key会被自动加上编号
    },
    "- Visual Studio Code":{
	"utf":{"name":"UTF-8 Header", "string":"# -*- coding: utf-8 -*-"}
    }
}
```
