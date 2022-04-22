# 
## 下载字体
比如我这个[腾祥伯当行书简体](fonts.net.cn/font-34454719039.html),下载ttf文件到本地

## 代码修改

### 拷贝ttf文件到public目录

```
#ls 
public/TengXiangBoDangXingShuJianTi-2.ttf
```

### 修改constants.ts
```
// 1-based in case we ever do `if(element.fontFamily)`
export const FONT_FAMILY = {
  Virgil: 1,
  Helvetica: 2,
  Cascadia: 3,
  AiDeMuGuangWuSuoBuZai:4,
  TengXiangBoDangXingShuJianTi: 5,
};
```
### 修改 src/actions/actionProperties.tsx
增加TengXiangBoDangXingShuJianTi相关配置
```
  PanelComponent: ({ elements, appState, updateData }) => {
    const options: {
      value: FontFamilyValues;
      text: string;
      icon: JSX.Element;
    }[] = [
      {
        value: FONT_FAMILY.Virgil,
        text: t("labels.handDrawn"),
        icon: <FontFamilyHandDrawnIcon theme={appState.theme} />,
      },
      {
        value: FONT_FAMILY.Helvetica,
        text: t("labels.normal"),
        icon: <FontFamilyNormalIcon theme={appState.theme} />,
      },
      {
        value: FONT_FAMILY.Cascadia,
        text: t("labels.code"),
        icon: <FontFamilyCodeIcon theme={appState.theme} />,
      },
      {
        value: FONT_FAMILY.AiDeMuGuangWuSuoBuZai,
        text: t("labels.handDrawn"),
        icon: <FontFamilyHandDrawnIcon theme={appState.theme} />,
      },
      {
        value: FONT_FAMILY.TengXiangBoDangXingShuJianTi,
        text: t("labels.handDrawn"),
        icon: <FontFamilyHandDrawnIcon theme={appState.theme} />,
      },
    ];//AiDeMuGuangWuSuoBuZai-2.ttf
```
### 修改 public/index.html
增加TengXiangBoDangXingShuJianTi
```
    <!-- Excalidraw version -->
    <meta name="version" content="{version}" />

    <link
      rel="preload"
      href="Virgil.woff2"
      as="font"
      type="font/woff2"
      crossorigin="anonymous"
    />
    <link
      rel="preload"
      href="Cascadia.woff2"
      as="font"
      type="font/woff2"
      crossorigin="anonymous"
    />
    <link
      rel="preload"
      href="AiDeMuGuangWuSuoBuZai-2.ttf"
      as="font"
      type="font/ttf"
      crossorigin="anonymous"
    />
    <link
      rel="preload"
      href="TengXiangBoDangXingShuJianTi-2.ttf"
      as="font"
      type="font/ttf"
      crossorigin="anonymous"
    />
```
### 修改 public/fonts.css
```
/* http://www.eaglefonts.com/fg-virgil-ttf-131249.htm */
@font-face {
  font-family: "Virgil";
  src: url("Virgil.woff2");
  font-display: swap;
}

/* https://github.com/microsoft/cascadia-code */
@font-face {
  font-family: "Cascadia";
  src: url("Cascadia.woff2");
  font-display: swap;
}
@font-face {
  font-family: "AiDeMuGuangWuSuoBuZai";
  src: url("AiDeMuGuangWuSuoBuZai-2.ttf");
  font-display: swap;
}
@font-face {
  font-family: "TengXiangBoDangXingShuJianTi";
  src: url("TengXiangBoDangXingShuJianTi-2.ttf");
  font-display: swap;
}
```
