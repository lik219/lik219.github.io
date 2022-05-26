# VBlog
![](https://img.shields.io/github/languages/top/github-laziji/VBlog.svg?style=flat)
![](https://img.shields.io/github/stars/gitHub-laziji/VBlog.svg?style=social)

## 目录
- [简介](#简介)
- [演示地址](#演示地址)
- [项目源码](#项目源码)
- [项目特点](#项目特点)
- [更新记录](#更新记录)
- [快速使用](#快速使用)

## 简介

博客可搭建在 GitHub Pages 上,
文章数据储存于gist 中, 通过Github API 与数据进行交互, 实现无后台、可动态发布文章的博客系统

## 演示地址
[https://lik219.github.io]

## 项目源码
[https://github.com/GitHub-Laziji/vblog]

## 项目特点

- [x] 基于 GitHub Pages 无需服务器
- [x] 改进传统 GitHub Pages 不能动态发布的缺陷
- [x] 包含电脑端和移动端
- [x] 单页面应用

## 更新记录

#### 2022.5.20 更新
- 修复API接口更新后源码中Token无法绑定问题
- 格式化代码方便查看、编辑

#### 更新说明
- 原作者已长期未更新，本人在原作者基础上进行了自己的适量修改更新

## 快速使用
搭建博客只需2步
- 点击github头像旁边的 "+" 号 选择 ```Import repository ```克隆地址填 ```https://github.com/lik219/lik219.github.io ```项目名填 ```你的用户名.github.io ```
- 克隆完成后 修改文件 ```/static/configuration.json``` 中的 ```githubUsername``` 为自己的github用户名

类似演示地址其中 lik219 为我的用户名

现在 ```https://你的用户名.github.io``` 就是你的个人博客了。

#### 获取Token

在 ```github > settings > Developer settings > Personal access tokens```  勾选```gist``` 和 ```repo```权限 获取```Token```

------

作者 *Laziji*
修改 *lik219*
