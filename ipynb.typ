#set page(
  paper:"a4"
)
#set text(
  size:16pt,  
  font:"DejaVu serif"
)

#block[
= Modelagem Estatística - Sobredispersão em Modelos de Contagem
<modelagem-estatística---sobredispersão-em-modelos-de-contagem>
#strong[Aluno];: Pedro Santos Tokar | #strong[Curso];: Ciência de Dados
e Inteligência Artificial, 5º período | #strong[Matrícula];: 231708008

== Introdução
<introdução>
Este documento é referente ao trabalho auxiliar passado na matéria de
Modelagem Estatística, ofertada na FGV - EMAp. A motivação do trabalho é
ter uma experiência prática com o ajuste de modelos estatísticos (mais
específicamente, o GLM Poisson). Durante o desenvolvimento deste
trabalho, uma base de dados reais será analisada e diferentes modelos
estatísticos serão ajustados aos dados desta base. Os resultados de cada
modelo serão discutidos e usados para exemplificar conceitos conhecidos
da modelagem estatística.

] <a928ba25-8b7a-484f-bb1d-9a39bd3423e9>
#block[
] <51278e60-c72b-414c-9848-9cf251f1f4c3>
#block[
== 1. Entendendo os dados
<1-entendendo-os-dados>
Iremos trabalhar com a base de dados #emph[RecreationDemand];,
disponível no pacote `Applied Econometrics with R`. Ela contém
informações sobre o número de viagens recreativas de barco para o Lago
Somerville que foram feitas por donos de barcos de lazer no leste do
Texas, em 1980. O dataset conta com 8 variáveis, e iremos analisar cada
uma para entender seu significado.

] <0350dd90-6651-441a-8e13-b4201e76f31a>
#block[
#block[
```
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 659 entries, 0 to 658
Data columns (total 8 columns):
 #   Column   Non-Null Count  Dtype  
---  ------   --------------  -----  
 0   trips    659 non-null    int64  
 1   quality  659 non-null    int64  
 2   ski      659 non-null    object 
 3   income   659 non-null    int64  
 4   userfee  659 non-null    object 
 5   costC    659 non-null    float64
 6   costS    659 non-null    float64
 7   costH    659 non-null    float64
dtypes: float64(3), int64(3), object(2)
memory usage: 41.3+ KB
```

]
] <f5ca5f89-85f9-44b1-aabe-99d2fe7f03fb>
#block[
A primeira variável é a `trips`. Ela representa a quantidade de passeios
de barco que os proprietários fizeram para o Lago Sommervile, e é a
nossa #strong[variável dependente];, pois é ela que temos interesse em
regredir. A utilidade dessa regressão está em entender que fatores
(principalmente econômicos) podem ou não influenciar a decisão de uma
pessoa de visitar ou não o lago a passeio.

] <49b3024c-cc2d-4e55-a10b-d0a8f937ae89>
#block[
#block[
```
'Média: 2.244309559939302 | Mediana: 0.0 | Variância: 39.59523732651941 | Desvio Padrão: 6.292474658393104'
```

]
] <97f57aa2-c71c-45e8-a06e-92a433ae153b>
#block[
#block[
#figure(
  image("./media/9105d65b8a990e2211df5a785e0476f27b9b4ac8.png"),
  caption: [legenda]
)

]
] <7270a238-5b51-4ea8-afae-d58819cd76e4>
#block[
Percebemos aqui que o dataset está ordenado seguindo essa variável, e
que ela contém apenas observações positivas, como o esperado. Sua média
é 2,24 viagens e sua variância é 39. Notamos logo de cara que, de quase
700 registros, mais de 400 deles tem valores 0. Para observar melhor a
distribuição da variável, é possível plotar ignorando valores 0:

] <8a1a9025-a562-41fe-b81b-f4c1dce3547d>
#block[
#block[
```
'Contagem de 0s: 417'
```

]
] <ff789ac0-cbd9-43ca-876e-b2a7174047a4>
#block[
#block[
```
Text(0, 0.5, 'Trips')
```

]
#block[
#figure(
  image("./media/d05c87558c77026b8f41d6a04418777c2e72341b.png"),
  caption: [legenda]
)

]
] <f539d346-9f7c-476c-a203-c2ba58e4e7b4>
#block[
Observamos que a grande maioria dos valores está abaixo de 20, com
números menores de observações com valores mais altos, o valor máximo na
casa do 80 (perto de alcançar a terceira casa decimal). Essa
característica, aliada ao fato do domínio da variável ser os números
naturais, torna adequado o uso de modelos como o de Poisson, que é capaz
de modelar dados de contagens. Mais da metade das observações ser 0 pode
ser um problema para a regressão, mas a principio isso será ignorado.

A segunda variável do dataset é a `quality`. Ao contrário da maioria das
#strong[variáveis independentes] do dataset, ela não é relacionada a um
indicador econômico, e sim a avaliação que quem visitou o lago deu a
ele. Quando observamos sua distribuição, vemos algo claro: temos
novamente diversos valores 0, que são relacionados em sua maioria a quem
não visitou o lago, mas também incluem pessoas que visitam o lago e não
deram uma nota. Mais notavelmente ainda, existem alguns casos de pessoas
que não visitaram mas deram uma nota (há menos zeros nessa coluna do que
na de trips!).

] <ac8140f7-f8ef-416f-a6bd-d53e6a40c90b>
#block[
#block[
```
'Contagem de 0s: 374 | Média contando 0s: 1.4188163884673748 | Média sem 0s: 3.280701754385965 | Variância sem 0s: 1.477267111440573'
```

]
] <b184c9ac-3363-462b-9b67-4cd4e399b8af>
#block[
#block[
#figure(
  image("./media/78f196e369d7221ec4177bb338a7b0829a18b51a.png"),
  caption: [legenda]
)

]
] <f07697c1-7961-4e31-b79e-bd1495fce7ec>
#block[
A média dessa variável é melhor interpretada quando calculamos sem
contar valores de 0, já que indicam que o lago não foi avaliado. Nesse
caso, temos média 3,28, indicando que há muitas avaliações
intermediárias (confirmado pelo histograma).

A terceira variável, `ski`, também não é relacionada a fatores
economicos/financeiros, e sim uma variável binária indicando se o
entrevistado esquiava no lago enquanto passeava de barco. Naturalmente,
para essa variável funcionar bem no modelo, precisamos convertê-la para
valores numéricos (0 para não e 1 para sim). Analisando os histogramas,
percebemos que pessoas que esquiam acabam fazendo mais viagens ao lago,
sendo que a maioria dos valores pequenos de visitas são associados a
pessoas que não visitaram tanto o lago.

] <4ff0058f-ccf3-4a62-9199-5579d7015be1>
#block[
] <3ba280d3-215e-48d7-8fa6-a8805f28921e>
#block[
#block[
```
ski
0    417
1    242
Name: count, dtype: int64
```

]
] <2527517d-bbed-427d-abd3-c4be8d04f303>
#block[
#block[
```
Text(0.5, 0, 'Trips (ski é 1)')
```

]
#block[
#figure(
  image("./media/927058aa580a326f8637d203477f76c14fd9ff4a.png"),
  caption: [legenda]
)

]
] <37734852-51d0-4de2-9435-bc5a05f7f5f7>
#block[
A quarta variável, `income`, corresponde à renda familiar do
entrevistado. Os valores não são exatos e estão divididos em intervalos
de 1000 dólares, o que na prática faz ela ser uma variável categórica.
Ainda assim, poderemos tratar como variável contínua na interpretação
dos resultados, já que as divisões são baseadas em valores contínuos, e
de certa forma valores intermediários entre as categorias têm
interpretação válida.

Essa variável não tem valores nulos ou faltantes, e suas estatísticas,
em conjunto com seu histograma, indicam que não há outliers e que seu
intervalo é bem definido (1 à 9).

] <b5ad39ec-039f-4151-9fd2-8b53b5145560>
#block[
#block[
```
'Média: 3.8528072837632776 | Mediana: 3.0 | Variância: 3.429669158852641 | Desvio Padrão: 1.8519365968770747'
```

]
] <2018d8d7-c74d-4066-ab6a-c6274d2d2299>
#block[
#block[
#figure(
  image("./media/6abb1a31f9ddeb5bbf33b825f27b3b0698a85a8c.png"),
  caption: [legenda]
)

]
] <4afd2918-cfec-4792-a4a6-721452fc9f5d>
#block[
Observamos, pelo scatterplot, que as pessoas com mais visitas ao lago
não necessariamente tem mais renda familiar.

A variável `userfee` também é uma variável binária, indicando se o dono
de barco pagou uma taxa anual de uso do lago. Novamente se faz
necessário dar um tratamento adequado para a variável, convertendo seus
valores para 0 e 1. O que observamos do plot dos histogramas e das
contagens é que apenas 13 entrevistados pagaram essa taxa, e o número de
passeios que eles fizeram tem uma range ampla, mas acima de 3.

] <ce45665a-43de-4bca-ad7f-2d65d07db040>
#block[
] <0d29b594-60e3-4d90-8411-937323b6fd45>
#block[
#block[
```
userfee
0    646
1     13
Name: count, dtype: int64
```

]
] <b9d5b3d4-6796-4ab8-b5fc-5b36fd5eb463>
#block[
#block[
#figure(
  image("./media/f24f7cb66c6ce2c23f69f063841a0bac765f21f9.png"),
  caption: [legenda]
)

]
] <e7ee790a-0932-4a09-8eeb-bc7d9c845635>
#block[
As últimas variáveis do dataset tem funções semelhantes: `costC`,
`costS` e `costH` indicam os #strong[custos de oportunidade];, estimados
em dólares, para cada entrevistado ir ou ao lago Conroe, ou ao lago
Sommerville ou ao lago Houston, todos localizados no Texas com distância
de carro entre eles abaixo de 2 horas.

Em outras palavras, são estimativas de quanto a pessoa gastaria para ir
a algum desses três lagos, acrescidos de quanto ela \"deixaria de
ganhar\" indo aos outros. Esse é um conceito de economia bem conhecido,
e é dado como melhor do que estimar apenas o gasto em dinheiro que
ocorreria com a ida. A utilidade dessas variáveis em nossa regressão é
entender se o custo de oportunidade de ir aos outros lagos influencia na
quantidade de viagens ao lago de interesse. Porém, ao analisá-las,
observamos que elas tem a distribuição muito próxima.

] <4e6d5568-01ce-454e-8d23-01d74805c44d>
#block[
#block[
#figure(
  image("./media/9e845cee334d3db5277f9925646c84dbb4cbd948.png"),
  caption: [legenda]
)

]
] <c0594deb-7d0c-4ac9-89c4-579941054713>
#block[
Podemos inspecionar melhor como essas variáveis se relacionam entre si e
entre a variável de interesse plotando alguns scatterplots que mostrem
as distribuições entre cada uma delas e delas com a variável de
interesse.

] <96df8bd2-536a-4956-8f19-f8ba8e1c9a48>
#block[
#block[
#figure(
  image("./media/9c8d7ff1ccc06ba976173871cb59c8f6cd87fd4c.png"),
  caption: [legenda]
)

]
] <6b9927d1-d288-4e39-97de-51d7055151d6>
#block[
Após inspecionar esses scatterplots, esperamos que:

- A correlação entre as variáveis de custo seja #strong[muito] alta;
- A correlação delas com a variável de interesse seja baixa, já que a
  relação não parece ser linear.

Verificaremos isso fazendo uma matriz de correlação entre as variáveis
do nosso dataset:

] <61bb6543-82b3-4e49-8661-851064af7800>
#block[
#block[
#figure(
  image("./media/eaf0633fc26f530892e786d24badaeefd34bde66.png"),
  caption: [legenda]
)

]
] <9dffd41a-3b27-4b0a-b58c-0969943434a8>
#block[
Como a matriz mostra, as três variáveis de custo têm correlações maiores
do que 95% entre elas. Além disso, a variável de custo ao lago de
interesse (Sommerville) tem correlação com a variável de interesse maior
em módulo do que a das outras duas, mas ainda assim com módulo muito
baixo. Isso indica que, entre elas, essa pode ser a mais importante para
o modelo. Além da matriz de correlação, uma métrica muito útil para
definirmos se essas variáveis entrarão na regressão é o Fator de
Inflação de Variância (em inglês, VIF).

] <3cc916af-25c5-428d-9c1f-76de6a54f317>
#block[
#block[
```
               0         1         2         3           4          5  \
coluna   quality       ski    income   userfee       costC      costS   
VIF     1.717989  1.792726  3.190647  1.065486  131.397142  61.328934   

                6  
coluna      costH  
VIF     93.752282  
```

]
] <a73fb12c-696f-4a72-b289-56885e6dd40f>
#block[
Todas elas tem VIF muito maior do que os recomendados 5 pontos para a
remoção de um modelo. Introduzir elas no modelo pode causar uma
instabilidade numérica em sua avaliação. Mesmo se tratando de um GLM,
que usa métodos iterativos para maximizar a verossimilhança e não
calcula a matriz $(X^T X)^(- 1)$, ainda assim ter variáveis muito
próximas da colinearidade prejudica os cálculos da convergência do
modelo.

Todas essas análises sobre as últimas variáveis levam à uma preocupação
quanto a contribuição delas para o modelo que será ajustado. Existe a
possibilidade delas introduzirem mais problemas do que ajudar na
construção do modelo, levando a conclusões errôneas.

Uma possível forma de mitigar os efeitos negativos ao ajuste que a
inclusão dessas variáveis traria é remover duas delas e deixar apenas
uma. Nessa abordagem, o significado prático das variáveis leva à
conclusão de que seria melhor manter a varíavel `costS` e remover as
outras duas, já que o custo que mais influenciaria a ida ao lago seria o
dele mesmo.

Porém, vale observar que essa abordagem tira do modelo uma capacidade
que pode ser interessante: inferir se a diferença entre essa variáveis
influencia na decisão (ou seja, se um lago ter um custo menor de ida que
o outro muda a quantidade de viagens que uma pessoa fez a ele). Mantendo
apenas uma variável, o potencial de comparação é perdido. Ao mesmo
tempo, manter duas delas segue fazendo o VIF delas ser alto:

] <2fa793e0-6b7c-4b39-b30d-042d100de13d>
#block[
#block[
```
               0         1         2         3         4          5
coluna   quality       ski    income   userfee     costS      costH
VIF     1.712896  1.785848  3.115096  1.062281  42.90048  40.775716
```

]
] <8685a3f1-28c8-49ec-9fc8-a7b0a560b3e5>
#block[
Pensando em manter o potencial de interpretação que essas variáveis
podem trazer e ao mesmo tempo evitar os problemas de colinearidade, é
possível fazer uma transformação que mantenha informações úteis para
inferência e remova as colunas sem muita perda de informação. Tendo em
vista o significado das variáveis e visando não aumentar muito a
complexidade da base, uma transformação possível é introduzir uma coluna
`isCheapest`, com valores binários:

- 1 (verdadeiro) caso `costS` \< `costC` e `costS` \< `costH`.
- 0 (falso) caso contrário.

] <d55ea8e5-0648-4d9f-9da7-9e2c1adfded2>
#block[
#block[
```
               0         1         2         3         4           5
coluna   quality       ski    income   userfee     costS  isCheapest
VIF     1.899121  1.785035  3.042713  1.081909  2.352996    1.554768
```

]
] <968df9da-ac17-43dc-a488-dc52b9e45186>
#block[
#block[
```
isCheapest
0    505
1    154
Name: count, dtype: int64
```

]
] <9bbe6d51-33de-40e9-af8f-a1dcc4707bcf>
#block[
#block[
#figure(
  image("./media/6bbacf0fb3e8617be04042af2a40d66061e09a95.png"),
  caption: [legenda]
)

]
] <b30dea9c-cce8-4fa7-8b82-98adaaf8ccee>
#block[
#block[
#figure(
  image("./media/471754615e194fe0c91aaf462b240421650e7c68.png"),
  caption: [legenda]
)

]
] <cea7d11d-09b7-489a-9102-b8a206706aca>
#block[
A análise dessa nova variável parece mostrar que ela pode ser uma boa
escolha para o ajuste do modelo, por mitigar os problemas causados pelas
outras sem \"jogar fora\" totalmente o potêncial informativo que elas
tinham. As distribuições do número de viagens para entradas em que ela é
verdadeira mostra que ela pode ser bem impactante na decisão de uma
pessoa de visitar ou não o lago. A correlação de 44% também corrobora
com esse pensamento.

Para por a prova o que foi levantado nesta análise, é possível ajustar
mais de um modelo, com diferentes escolhas de variáveis, e analisar qual
se ajusta melhor aos dados.

== 2. Ajustando modelos Poisson
<2-ajustando-modelos-poisson>
Aqui, serão ajustados 3 modelos lineares generalizados da família
Poisson, devido à natureza da variável dependente. A função de ligação
desse modelo é o logarítmo natural $l o g (.)$. O ajuste será feito de
maneira frequentista, usando o Estimador de Máxima Verossimilhança.
Devido à natureza desse modelo (e dos GLMs num geral), o ajuste é feito
por métodos numéricos iterativos, que convergem para a solução de máxima
verossimilhança.

Todos eles serão ajustados com as variáveis `quality`, `ski`, `income` e
`userfee`, pois nenhuma delas apresentou sinais de que não tinha
influência nenhuma na variável de interesse (a variável `quality` tinha
algumas entradas suspeitas, mas a correlação dela com a variável
dependente pode ser um sinal de que ela será uma boa preditora). Já as
variáveis de custo terão um tratamento especial: o primeiro modelo será
ajustado com as três variáveis, o segundo apenas com a `costS` e o
terceiro com a `costS` e a nova variável `isCheapest`.

] <a6aba904-2273-47ee-8301-3cae033b60d0>
#block[
#block[
```
<class 'statsmodels.iolib.summary.Summary'>
"""
                 Generalized Linear Model Regression Results                  
==============================================================================
Dep. Variable:                  trips   No. Observations:                  659
Model:                            GLM   Df Residuals:                      651
Model Family:                 Poisson   Df Model:                            7
Link Function:                    Log   Scale:                          1.0000
Method:                          IRLS   Log-Likelihood:                -1529.4
Date:                Mon, 02 Jun 2025   Deviance:                       2305.8
Time:                        11:43:35   Pearson chi2:                 4.10e+03
No. Iterations:                     8   Pseudo R-squ. (CS):             0.9789
Covariance Type:            nonrobust                                         
==============================================================================
                 coef    std err          z      P>|z|      [0.025      0.975]
------------------------------------------------------------------------------
const          0.2650      0.094      2.827      0.005       0.081       0.449
quality        0.4717      0.017     27.602      0.000       0.438       0.505
ski            0.4182      0.057      7.313      0.000       0.306       0.530
income        -0.1113      0.020     -5.683      0.000      -0.150      -0.073
userfee        0.8982      0.079     11.371      0.000       0.743       1.053
costC         -0.0034      0.003     -1.100      0.271      -0.010       0.003
costS         -0.0425      0.002    -25.466      0.000      -0.046      -0.039
costH          0.0361      0.003     13.335      0.000       0.031       0.041
==============================================================================
"""
```

]
] <c48d8434-c803-432e-a545-6a560c2b9c5d>
#block[
#block[
```
<class 'statsmodels.iolib.summary2.Summary'>
"""
               Results: Generalized linear model
===============================================================
Model:              GLM              AIC:            3074.8626 
Link Function:      Log              BIC:            -1919.6755
Dependent Variable: trips            Log-Likelihood: -1529.4   
Date:               2025-06-02 11:43 LL-Null:        -2801.4   
No. Observations:   659              Deviance:       2305.8    
Df Model:           7                Pearson chi2:   4.10e+03  
Df Residuals:       651              Scale:          1.0000    
Method:             IRLS                                       
----------------------------------------------------------------
            Coef.   Std.Err.     z      P>|z|    [0.025   0.975]
----------------------------------------------------------------
const       0.2650    0.0937    2.8274  0.0047   0.0813   0.4487
quality     0.4717    0.0171   27.6016  0.0000   0.4382   0.5052
ski         0.4182    0.0572    7.3126  0.0000   0.3061   0.5303
income     -0.1113    0.0196   -5.6831  0.0000  -0.1497  -0.0729
userfee     0.8982    0.0790   11.3713  0.0000   0.7434   1.0530
costC      -0.0034    0.0031   -1.1000  0.2713  -0.0095   0.0027
costS      -0.0425    0.0017  -25.4657  0.0000  -0.0458  -0.0393
costH       0.0361    0.0027   13.3353  0.0000   0.0308   0.0414
===============================================================

"""
```

]
] <50b233a9-bb53-4af2-b6d2-41e474947353>
#block[
Observamos que o modelo com todas as variáveis apresenta um
pseudo-$R_(C S)^2$ de aproximadamente $0 , 98$. Essa métrica é o
pseudo-$R^2$ de Cox e Snell, usado em modelos lineares generalizados e
parametrizado como
$R_(C S)^2 = 1 - e x p { 2 / n (l n (L_0) - l n (L_M)) }$. Ele é uma
generalização do $R^2$ já conhecido para modelos que não são ajustados
por mínimos quadrados, e sim por maxima verossimilhança.

Nos GLM, ele não é interpretado como a porcentagem da variância
explicada, e sim como uma melhoria no ajuste do modelo (tanto que ele
pode nem chegar a um para regressões logísticas), e ainda mantém a
propriedade de quanto maior, melhor.

Podemos ver que todos as estimativas de regressores, com excessão do
associado à variável `costC`, são estatísticamente significativos. Esse
resultado pode parecer bom, mas é preciso tomar cuidado e se ter em
mente que o VIF das variáveis de custo eram bem altos, e que isso pode
interferir nas estatísticas e testes do modelo.

] <a0b00dcb-d339-4fb3-8539-8f882ff64e9f>
#block[
#block[
```
<class 'statsmodels.iolib.summary2.Summary'>
"""
               Results: Generalized linear model
===============================================================
Model:              GLM              AIC:            3452.5604 
Link Function:      Log              BIC:            -1550.9591
Dependent Variable: trips            Log-Likelihood: -1720.3   
Date:               2025-06-02 11:43 LL-Null:        -2801.4   
No. Observations:   659              Deviance:       2687.5    
Df Model:           5                Pearson chi2:   5.82e+03  
Df Residuals:       653              Scale:          1.0000    
Method:             IRLS                                       
----------------------------------------------------------------
            Coef.   Std.Err.     z      P>|z|    [0.025   0.975]
----------------------------------------------------------------
const       0.5861    0.0919    6.3771  0.0000   0.4060   0.7662
quality     0.5408    0.0159   33.9241  0.0000   0.5096   0.5721
ski         0.4542    0.0565    8.0440  0.0000   0.3435   0.5649
income     -0.1578    0.0195   -8.0930  0.0000  -0.1961  -0.1196
userfee     1.1015    0.0799   13.7860  0.0000   0.9449   1.2581
costS      -0.0153    0.0010  -15.0975  0.0000  -0.0173  -0.0133
===============================================================

"""
```

]
] <f17c7bf9-2df5-4c20-83f7-6f22de0065d6>
#block[
#block[
```
<class 'statsmodels.iolib.summary2.Summary'>
"""
               Results: Generalized linear model
===============================================================
Model:              GLM              AIC:            3452.5604 
Link Function:      Log              BIC:            -1550.9591
Dependent Variable: trips            Log-Likelihood: -1720.3   
Date:               2025-06-02 11:43 LL-Null:        -2801.4   
No. Observations:   659              Deviance:       2687.5    
Df Model:           5                Pearson chi2:   5.82e+03  
Df Residuals:       653              Scale:          1.0000    
Method:             IRLS                                       
----------------------------------------------------------------
            Coef.   Std.Err.     z      P>|z|    [0.025   0.975]
----------------------------------------------------------------
const       0.5861    0.0919    6.3771  0.0000   0.4060   0.7662
quality     0.5408    0.0159   33.9241  0.0000   0.5096   0.5721
ski         0.4542    0.0565    8.0440  0.0000   0.3435   0.5649
income     -0.1578    0.0195   -8.0930  0.0000  -0.1961  -0.1196
userfee     1.1015    0.0799   13.7860  0.0000   0.9449   1.2581
costS      -0.0153    0.0010  -15.0975  0.0000  -0.0173  -0.0133
===============================================================

"""
```

]
] <e86ac693-fe71-4ef2-bee2-3f994fe55ab4>
#block[
Removendo as variáveis de custo que não são referentes ao lago
Sommerville, observamos uma piora em algumas métricas: o AIC e Deviance
são maiores (o que é indesejável) e o pseudo-$R^2$ é menor, ainda que
por pouca diferença. Também observamos que a verossimilhança é menor,
indicando uma menor compatibilidade entre os dados reais e as previsões.

Esse aumento pode indicar que a remoção das variáveis trouxe uma perda
de poder preditivo, mesmo que estabilizasse a convergência do modelo e
suas estatísticas.

] <ddfda176-2438-4d78-9773-5d8c258314c8>
#block[
#block[
```
<class 'statsmodels.iolib.summary.Summary'>
"""
                 Generalized Linear Model Regression Results                  
==============================================================================
Dep. Variable:                  trips   No. Observations:                  659
Model:                            GLM   Df Residuals:                      652
Model Family:                 Poisson   Df Model:                            6
Link Function:                    Log   Scale:                          1.0000
Method:                          IRLS   Log-Likelihood:                -1434.1
Date:                Mon, 02 Jun 2025   Deviance:                       2115.1
Time:                        11:43:35   Pearson chi2:                 4.04e+03
No. Iterations:                     6   Pseudo R-squ. (CS):             0.9842
Covariance Type:            nonrobust                                         
==============================================================================
                 coef    std err          z      P>|z|      [0.025      0.975]
------------------------------------------------------------------------------
const         -0.4750      0.108     -4.418      0.000      -0.686      -0.264
quality        0.4259      0.018     24.026      0.000       0.391       0.461
ski            0.4920      0.055      8.882      0.000       0.383       0.601
income        -0.0768      0.019     -4.099      0.000      -0.113      -0.040
userfee        0.6083      0.081      7.508      0.000       0.450       0.767
costS         -0.0093      0.001     -9.947      0.000      -0.011      -0.007
isCheapest     1.5037      0.067     22.541      0.000       1.373       1.634
==============================================================================
"""
```

]
] <705ffc6f-67cb-40fe-92fd-7443d9b48af4>
#block[
#block[
```
<class 'statsmodels.iolib.summary2.Summary'>
"""
               Results: Generalized linear model
===============================================================
Model:              GLM              AIC:            2882.1280 
Link Function:      Log              BIC:            -2116.9007
Dependent Variable: trips            Log-Likelihood: -1434.1   
Date:               2025-06-02 11:43 LL-Null:        -2801.4   
No. Observations:   659              Deviance:       2115.1    
Df Model:           6                Pearson chi2:   4.04e+03  
Df Residuals:       652              Scale:          1.0000    
Method:             IRLS                                       
----------------------------------------------------------------
             Coef.   Std.Err.     z     P>|z|    [0.025   0.975]
----------------------------------------------------------------
const       -0.4750    0.1075  -4.4181  0.0000  -0.6857  -0.2643
quality      0.4259    0.0177  24.0258  0.0000   0.3911   0.4606
ski          0.4920    0.0554   8.8816  0.0000   0.3835   0.6006
income      -0.0768    0.0187  -4.0987  0.0000  -0.1135  -0.0401
userfee      0.6083    0.0810   7.5079  0.0000   0.4495   0.7671
costS       -0.0093    0.0009  -9.9470  0.0000  -0.0111  -0.0074
isCheapest   1.5037    0.0667  22.5405  0.0000   1.3729   1.6344
===============================================================

"""
```

]
] <450e7648-8606-4bd3-9967-fe9aa77d0763>
#block[
O terceiro modelo apresenta todas as métricas melhores: seu AIC e sua
Deviance são menores que dos outros, indicando que mesmo com menos
features, o modelo pode se ajustar melhor aos dados. O pseudo-$R^2$ é
maior, também reforçando a ideia de que muito da variância foi
explicada.

É possível ver que todas as estimativas de parâmetros são
estatísticamente significantes, e para esse modelo esses resultados são
mais confiáveis, principalmente quando se leva em conta que o VIF de
todas as variáveis independentes usadas era menor do que 5. A log
verossimilhança também é menor, o que é mais um bom sinal.

Para auxiliar na análise da bondade de ajuste desses modelos, podemos
fazer plots de valor predito por resíduo de Pearson. Os resíduos de
Pearson são definidos por
$r_i^P = frac(y_i - hat(mu)_i, s q r t (hat(mu)_i))$ e são padronizados,
levando em conta qual seria a variância para um preditor da média. Por
não estarmos lidando com um modelo linear, não é possível esperar que
esses resíduos se distribuam uniformemente, mas é esperado, pela
padronização, que eles fiquem distribuidos perto de 0 e a que a grande
maioria fique no range (-2, 2).

O objetivo dessa padronização é se adaptar ao fato de que, na regressão
Poisson, a variância dos dados aumenta junto com a média, e tornar esses
resíduos mais uniformes mesmo com o aumento da média (que aqui é a
previsão do modelo).

] <9d0781a9-5087-41df-b5e7-026d6ded75b5>
#block[
#block[
#figure(
  image("./media/10c8bbe9d05a9c6ab671fe65ab7bffabca107143.png"),
  caption: [legenda]
)

]
] <ac957893-41db-4532-a7aa-01adbd28799e>
#block[
Dos plots, três observações saltam aos olhos:

- O primeiro e o segundo modelos tem resíduos padronizados que parecem
  ser menos dispersos a medida em que o valor do preditor aumenta, o que
  não acontece tão claramente com o terceiro modelo, que tem a
  distribuição desses resíduos mais consistente mesmo com as mudanças do
  preditor;
- Todos os modelos tem vários dos resíduos longe do 0, indo contra o que
  seria esperado da distribuição desses resíduos, que idealmente teriam
  desvio padrão 1;
- Os resíduos menores que 0 parecem se concentrar mais, enquanto os
  maiores que zero são mais espalhados e amplos.

A primeira observação corrobora com a ideia de que o terceiro modelo
conseguiu se ajustar melhor aos dados, mantendo uma distribuição dos
resíduos de Pearson mais próxima do que se espera. Já a segunda
observação é um forte indício de que todos os modelos sofreram de
sobredispersão.

Os resíduos estarem muito espalhados, mais do que o esperado, indica que
os valores reais estão muito distantes das previsões do modelo. Essa
distância pode se dar pela sobredispersão: o modelo não foi pensado para
lidar com dados com variância maior do que a média, e então não faz
previsões de acordo com a variância real.

É possível conduzir um teste estatístico formal para atestar se há ou
não sobredispersão no modelo. Para conduzir este teste, é necessário
escolher um dos modelos. Devido às métricas apresentadas serem melhores
e a distribuição dos resíduos de Pearson serem mais próximas do
esperado, o teste será conduzido com o terceiro modelo, que faz uso da
nova variável criada para o dataset.

== 3. Testando a sobredispersão
<3-testando-a-sobredispersão>
Para esse teste, queremos saber se rejeitamos ou não a hipotese nula:
para uma parametrização da variância como $V a r (Y) = mu + alpha mu^2$,
a hipotese nula é $H_0 : alpha = 0$. Os resultados da regressão de $Z_i$
em $hat(mu)_i$ obtidos foram:

] <83f39e8b-950d-446d-b131-b7dc35144dce>
#block[
] <8650ba12-22f0-4f93-9053-fc9692eec9f9>
#block[
#block[
```
<class 'statsmodels.iolib.summary.Summary'>
"""
                                 OLS Regression Results                                
=======================================================================================
Dep. Variable:                      y   R-squared (uncentered):                   0.010
Model:                            OLS   Adj. R-squared (uncentered):              0.009
Method:                 Least Squares   F-statistic:                              6.888
Date:                Mon, 02 Jun 2025   Prob (F-statistic):                     0.00888
Time:                        11:43:35   Log-Likelihood:                         -3572.5
No. Observations:                 659   AIC:                                      7147.
Df Residuals:                     658   BIC:                                      7151.
Df Model:                           1                                                  
Covariance Type:            nonrobust                                                  
==============================================================================
                 coef    std err          t      P>|t|      [0.025      0.975]
------------------------------------------------------------------------------
x1             1.2061      0.460      2.624      0.009       0.304       2.109
==============================================================================
Omnibus:                     1515.886   Durbin-Watson:                   1.038
Prob(Omnibus):                  0.000   Jarque-Bera (JB):          5268993.461
Skew:                          19.789   Prob(JB):                         0.00
Kurtosis:                     439.262   Cond. No.                         1.00
==============================================================================

Notes:
[1] R² is computed without centering (uncentered) since the model does not contain a constant.
[2] Standard Errors assume that the covariance matrix of the errors is correctly specified.
"""
```

]
] <8f9e83f0-8d3c-4632-bde0-1e10809ddddc>
#block[
Estatísticamente, obtivemos uma estatística de teste t igual à
$2 , 624$, cujo p-valor é $0 , 009$. Esse resultado indica significância
estatística, já que o p-valor está abaixo de 0,05. Logo, rejeitamos a
hipótese $H_0$, levando a conclusão de que existe sobredispersão. O
resultado do teste formal condiz com o que observamos nos resíduos dos
modelos na etapa anterior.

Tendo conhecimento da sobredispersão, não é vantajoso usar um modelo que
não é pensado para lidar com ela para fazer inferências e interpretações
sobre os dados. Por isso, é importante usar modelos que são pensados
para lidar com esse tipo de fenômeno.

== 4. Modelo Binomial Negativo
<4-modelo-binomial-negativo>
O modelo em questão, que consegue levar a sobredispersão em conta em seu
ajuste, é um modelo da família Binomial Negativa. Esse modelo, assim
como o de Poisson, modela dados cujo domínio é o conjunto dos números
naturais. A parametrização desse modelo lembra o teste que foi feito
acima:

$ E [Y_i \| X_i] = mu_i = exp { x_i^T beta } $

$ V a r (Y_i \| X_i) = mu_i + alpha mu_i^2 $

Essa variância é o que modela a sobredispersão: o valor $alpha$ é
estimado junto com o $beta$, e então o ajuste leva em conta a
sobredispersão, e o parâmetro $alpha$ ganha uma estimativa $hat(alpha)$
com intervalo de confiança. Como estamos lidando com dados inteiros
positivos, e como os dados de contagem geralmente abrangem várias
magnitudes (como vimos no nosso dataset também), a função de link deste
modelo é o logarítmo natural, função inversa da exponencial.

] <0aa169d1-13f4-480b-ab41-7685ac60eae2>
#block[
#block[
```
Optimization terminated successfully.
         Current function value: 1.269525
         Iterations: 32
         Function evaluations: 39
         Gradient evaluations: 39
```

]
#block[
```
/home/pedro/Modelos/Faculdade/venv/lib/python3.13/site-packages/statsmodels/discrete/discrete_model.py:3379: RuntimeWarning: divide by zero encountered in log
  llf = coeff + size*np.log(prob) + endog*np.log(1-prob)
/home/pedro/Modelos/Faculdade/venv/lib/python3.13/site-packages/statsmodels/discrete/discrete_model.py:3379: RuntimeWarning: invalid value encountered in multiply
  llf = coeff + size*np.log(prob) + endog*np.log(1-prob)
```

]
#block[
```
<class 'statsmodels.iolib.summary.Summary'>
"""
                     NegativeBinomial Regression Results                      
==============================================================================
Dep. Variable:                  trips   No. Observations:                  659
Model:               NegativeBinomial   Df Residuals:                      652
Method:                           MLE   Df Model:                            6
Date:                Mon, 02 Jun 2025   Pseudo R-squ.:                  0.2142
Time:                        11:43:35   Log-Likelihood:                -836.62
converged:                       True   LL-Null:                       -1064.7
Covariance Type:            nonrobust   LLR p-value:                 2.260e-95
==============================================================================
                 coef    std err          z      P>|z|      [0.025      0.975]
------------------------------------------------------------------------------
const         -1.6855      0.228     -7.393      0.000      -2.132      -1.239
quality        0.7132      0.046     15.582      0.000       0.624       0.803
ski            0.6324      0.153      4.143      0.000       0.333       0.932
income        -0.0595      0.045     -1.317      0.188      -0.148       0.029
userfee        0.7272      0.364      1.996      0.046       0.013       1.441
costS         -0.0057      0.002     -2.899      0.004      -0.010      -0.002
isCheapest     1.7376      0.156     11.154      0.000       1.432       2.043
alpha          1.4219      0.150      9.454      0.000       1.127       1.717
==============================================================================
"""
```

]
] <959f0a46-2023-4bf9-8389-5767df384e38>
#block[
#block[
```
<class 'statsmodels.iolib.summary2.Summary'>
"""
                    Results: NegativeBinomial
=================================================================
Model:              NegativeBinomial Pseudo R-squared: 0.214     
Dependent Variable: trips            AIC:              1689.2337 
Date:               2025-06-02 11:43 BIC:              1725.1595 
No. Observations:   659              Log-Likelihood:   -836.62   
Df Model:           6                LL-Null:          -1064.7   
Df Residuals:       652              LLR p-value:      2.2595e-95
Converged:          1.0000           Scale:            1.0000    
Method:             MLE                                          
------------------------------------------------------------------
               Coef.   Std.Err.     z     P>|z|    [0.025   0.975]
------------------------------------------------------------------
const         -1.6855    0.2280  -7.3926  0.0000  -2.1324  -1.2387
quality        0.7132    0.0458  15.5817  0.0000   0.6235   0.8029
ski            0.6324    0.1526   4.1430  0.0000   0.3332   0.9315
income        -0.0595    0.0452  -1.3166  0.1880  -0.1480   0.0291
userfee        0.7272    0.3642   1.9965  0.0459   0.0133   1.4411
costS         -0.0057    0.0020  -2.8992  0.0037  -0.0096  -0.0019
isCheapest     1.7376    0.1558  11.1538  0.0000   1.4323   2.0430
alpha          1.4219    0.1504   9.4545  0.0000   1.1271   1.7167
=================================================================

"""
```

]
] <d1921e4b-9562-4575-ac36-d68f3a8bb0d0>
#block[
] <4a30495f-453e-4c84-a9aa-5bb2e9514c1a>
#block[
Observamos que após o fit, o resultado contém as estimativas para os
regressores e também para o parâmetro da sobredispersão. A métrica do
pseudo-$R^2$ se mostrou bem menor em relação ao que estava sendo visto
na regressão Poisson, mas isso é esperado: o Modelo Poisson ignorava a
sobredispersão e ela não era levada em conta para fazer o ajuste e nem
calcular as métricas. Já o modelo Binomial Negativa, por levar em conta
a sobredispersão, incorpora o ajuste à esse fenômeno em sua
verossimilhança e por consequência no cálculo de métricas como o
pseudo-$R^2$.

Isso se reflete em um valor mais baixo, mas mais real e útil para
comparação de possíveis modelos com essa parametrização (ele não está
jogado para perto do 1, o que pode facilitar comparações).

] <378e3978-b065-4b83-8c29-5407f72459b8>
#block[
#block[
```
Text(0, 0.5, 'Resíduos de Pearson')
```

]
#block[
#figure(
  image("./media/010212c309a47f74a39e499a1bb8c5cff7934852.png"),
  caption: [legenda]
)

]
] <ddf62c61-5c38-46e7-8b15-4547ad573e30>
#block[
Observando o scatter plot dos resíduos contra os valores ajustados,
vemos que agora os resíduos se concentram dentro do range (-2, 2), ao
contrários dos resíduos dos modelos Poisson treinados, que eram muito
mais dispersos. Isso indica que o modelo conseguiu lidar melhor com a
sobredispersão dos dados, fazendo previsões mais \"amplas\". Esse
resultado é positivo, já que se deseja modelar o comportamento real dos
dados e todos os seus fenômenos intrinsecos.

É preciso ressaltar, porém, que os resíduos ainda apresentam
comportamentos estranhos. Assim como ocorreu com os modelos Poisson, os
resíduos negativos se concentram no intervalo esperado, enquanto alguns
positivos são muito espalhados. Esse último comportamento é
especialmente predominante em predições que foram próximas de 0. Esse
comportamento leva a conclusão de que:

- O modelo está errando mais para baixo do que para cima, ou seja, está
  predizendo muitos valores abaixo do esperado.
- Algumas dessas previsões tem erros que jogam elas para outras casas de
  magnitude abaixo do esperado.

Esses são sintomas de que o modelo está predizendo valores abaixo dos
que deveria predizer muito frequentemente, fugindo do comportamento que
se esperaria ver normalmente.

== Questão 5 - Modelo inflado de zeros
<questão-5---modelo-inflado-de-zeros>
] <e3501a11-5edf-4871-9c30-22c1bffb8533>
#block[
] <17dbfa03-4722-4889-a167-7bffd3492c5c>
#block[
] <76a890ef-de64-443f-9942-46dd801e2109>
#block[
] <59efda90-cb9a-4d32-8d32-9a6dbf358f93>
#block[
#block[
```
Optimization terminated successfully.
         Current function value: 2.109287
         Iterations: 26
         Function evaluations: 31
         Gradient evaluations: 31
```

]
#block[
```
<class 'statsmodels.iolib.summary.Summary'>
"""
                     ZeroInflatedPoisson Regression Results                    
===============================================================================
Dep. Variable:                   trips   No. Observations:                  659
Model:             ZeroInflatedPoisson   Df Residuals:                      652
Method:                            MLE   Df Model:                            6
Date:                 Mon, 02 Jun 2025   Pseudo R-squ.:                  0.2068
Time:                         11:43:35   Log-Likelihood:                -1390.0
converged:                        True   LL-Null:                       -1752.5
Covariance Type:             nonrobust   LLR p-value:                2.579e-153
=================================================================================
                    coef    std err          z      P>|z|      [0.025      0.975]
---------------------------------------------------------------------------------
inflate_const    -0.5157      0.129     -3.994      0.000      -0.769      -0.263
const             0.3076      0.126      2.450      0.014       0.062       0.554
quality           0.2961      0.022     13.669      0.000       0.254       0.339
ski               0.5072      0.057      8.826      0.000       0.395       0.620
income           -0.0760      0.020     -3.826      0.000      -0.115      -0.037
userfee           0.5418      0.081      6.717      0.000       0.384       0.700
costS            -0.0100      0.001    -10.233      0.000      -0.012      -0.008
isCheapest        1.2825      0.072     17.754      0.000       1.141       1.424
=================================================================================
"""
```

]
] <0428f21c-b895-4f1d-b81d-990897f71e40>
#block[
#block[
```
<class 'statsmodels.iolib.summary2.Summary'>
"""
                    Results: ZeroInflatedPoisson
=====================================================================
Model:              ZeroInflatedPoisson Pseudo R-squared: 0.207      
Dependent Variable: trips               AIC:              2796.0403  
Date:               2025-06-02 11:43    BIC:              2831.9661  
No. Observations:   659                 Log-Likelihood:   -1390.0    
Df Model:           6                   LL-Null:          -1752.5    
Df Residuals:       652                 LLR p-value:      2.5787e-153
Converged:          1.0000              Scale:            1.0000     
Method:             MLE                                              
----------------------------------------------------------------------
                  Coef.   Std.Err.     z      P>|z|    [0.025   0.975]
----------------------------------------------------------------------
inflate_const    -0.5157    0.1291   -3.9943  0.0001  -0.7688  -0.2627
const             0.3076    0.1256    2.4503  0.0143   0.0616   0.5537
quality           0.2961    0.0217   13.6692  0.0000   0.2537   0.3386
ski               0.5072    0.0575    8.8264  0.0000   0.3946   0.6198
income           -0.0760    0.0199   -3.8259  0.0001  -0.1149  -0.0371
userfee           0.5418    0.0807    6.7168  0.0000   0.3837   0.6999
costS            -0.0100    0.0010  -10.2328  0.0000  -0.0120  -0.0081
isCheapest        1.2825    0.0722   17.7544  0.0000   1.1410   1.4241
=====================================================================

"""
```

]
] <5083b118-42b3-4c38-933f-b936826b2ee0>
#block[
#block[
```
Text(0, 0.5, 'Resíduos de Pearson')
```

]
#block[
#figure(
  image("./media/80dc0f54ea4c9b13fce2683f9ff1dcb1dae18735.png"),
  caption: [legenda]
)

]
] <a4dea1d0-1973-4551-80d0-6bfde7283fd9>
#block[
#block[
```
         Current function value: 1.269550
         Iterations: 35
         Function evaluations: 38
         Gradient evaluations: 38
```

]
#block[
```
/home/pedro/Modelos/Faculdade/venv/lib/python3.13/site-packages/scipy/optimize/_optimize.py:1313: OptimizeWarning: Maximum number of iterations has been exceeded.
  res = _minimize_bfgs(f, x0, args, fprime, callback=callback, **opts)
/home/pedro/Modelos/Faculdade/venv/lib/python3.13/site-packages/statsmodels/base/model.py:607: ConvergenceWarning: Maximum Likelihood optimization failed to converge. Check mle_retvals
  warnings.warn("Maximum Likelihood optimization failed to "
/home/pedro/Modelos/Faculdade/venv/lib/python3.13/site-packages/statsmodels/base/model.py:595: HessianInversionWarning: Inverting hessian failed, no bse or cov_params available
  warnings.warn('Inverting hessian failed, no bse or cov_params '
/home/pedro/Modelos/Faculdade/venv/lib/python3.13/site-packages/statsmodels/base/model.py:595: HessianInversionWarning: Inverting hessian failed, no bse or cov_params available
  warnings.warn('Inverting hessian failed, no bse or cov_params '
```

]
#block[
```
<class 'statsmodels.iolib.summary.Summary'>
"""
                     ZeroInflatedNegativeBinomialP Regression Results                    
=========================================================================================
Dep. Variable:                             trips   No. Observations:                  659
Model:             ZeroInflatedNegativeBinomialP   Df Residuals:                      652
Method:                                      MLE   Df Model:                            6
Date:                           Mon, 02 Jun 2025   Pseudo R-squ.:                  0.2142
Time:                                   11:43:36   Log-Likelihood:                -836.63
converged:                                 False   LL-Null:                       -1064.7
Covariance Type:                       nonrobust   LLR p-value:                 2.297e-95
=================================================================================
                    coef    std err          z      P>|z|      [0.025      0.975]
---------------------------------------------------------------------------------
inflate_const   -10.1471     14.738     -0.688      0.491     -39.033      18.739
const            -1.6842      0.228     -7.393      0.000      -2.131      -1.238
quality           0.7132      0.046     15.590      0.000       0.624       0.803
ski               0.6353      0.153      4.163      0.000       0.336       0.934
income           -0.0599      0.045     -1.328      0.184      -0.148       0.029
userfee           0.7821      0.371      2.109      0.035       0.055       1.509
costS            -0.0057      0.002     -2.903      0.004      -0.010      -0.002
isCheapest        1.7320      0.156     11.134      0.000       1.427       2.037
alpha             1.4186      0.150      9.466      0.000       1.125       1.712
=================================================================================
"""
```

]
] <75927fef-1392-4cd0-a0fd-80a70bf81aab>
#block[
#block[
```
<class 'statsmodels.iolib.summary2.Summary'>
"""
                    Results: ZeroInflatedNegativeBinomialP
==============================================================================
Model:              ZeroInflatedNegativeBinomialP Pseudo R-squared: 0.214     
Dependent Variable: trips                         AIC:              1691.2665 
Date:               2025-06-02 11:43              BIC:              1731.6830 
No. Observations:   659                           Log-Likelihood:   -836.63   
Df Model:           6                             LL-Null:          -1064.7   
Df Residuals:       652                           LLR p-value:      2.2966e-95
Converged:          0.0000                        Scale:            1.0000    
Method:             MLE                                                       
---------------------------------------------------------------------------------
                  Coef.      Std.Err.       z       P>|z|      [0.025      0.975]
---------------------------------------------------------------------------------
inflate_const    -10.1471     14.7382    -0.6885    0.4911    -39.0335    18.7393
const             -1.6842      0.2278    -7.3931    0.0000     -2.1307    -1.2377
quality            0.7132      0.0457    15.5900    0.0000      0.6235     0.8029
ski                0.6353      0.1526     4.1631    0.0000      0.3362     0.9344
income            -0.0599      0.0451    -1.3276    0.1843     -0.1484     0.0285
userfee            0.7821      0.3708     2.1090    0.0349      0.0553     1.5089
costS             -0.0057      0.0020    -2.9034    0.0037     -0.0096    -0.0019
isCheapest         1.7320      0.1556    11.1345    0.0000      1.4271     2.0369
alpha              1.4186      0.1499     9.4664    0.0000      1.1249     1.7123
==============================================================================

"""
```

]
] <7b8db964-2489-4a49-8643-ffd128c6ae1e>
#block[
#block[
```
Text(0, 0.5, 'Resíduos de Pearson')
```

]
#block[
#figure(
  image("./media/7800ec2a94fba6c359749cbd5a0126442dd90e87.png"),
  caption: [legenda]
)

]
] <98afa06f-7e9b-4c8a-bc24-ed4edcdae389>
#block[
#block[
```
False    551
True     108
Name: count, dtype: int64
```

]
] <7f8ff8c8-56c8-4cb4-9e4f-7295a51d99f4>
#block[
] <1beb6738-1ead-4452-ac6c-ea7e463e68dd>
#block[
] <a8b191e6-db2b-4eac-88a4-f313f48600a1>
#block[
] <f2d3bd79-96ad-4a4f-bc72-eaca6ad3ad6e>
#block[
] <ba24cde5-83be-4b09-b315-e9da3ac744ff>
#block[
] <c60e49c3-ac14-4384-822c-6a5b0e7e27d0>
#block[
#block[
```
<matplotlib.lines.Line2D at 0x7753b57ae350>
```

]
#block[
#figure(
  image("./media/0ae0cdd44a9bcccdd82f30a4cf8a5ef5f0680450.png"),
  caption: [legenda]
)

]
] <a53f4d2c-d7f4-4443-ba7a-54d7d309fb73>
#block[
] <268a13ec-18c1-40c2-9664-9b6cdcfadf7e>
