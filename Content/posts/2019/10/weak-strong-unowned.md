---
description: Entendendo sobre ARC e como evitar vazamento de memória
date: 2019-10-05 21:24
tags: arc, swift
categories: Swift
keywords: weak, strong, unowned, swift, arc
comments: true
---
# Weak, Strong e Unowned

Antes de falarmos sobre o que significam as palavras-chave `weak`, `strong` e `unowned`, precisamos conhecer e entender o ARC do swift. Vamos lá?

*Caso queira pular o conteúdo sobre o ARC, vá para a sessão 6: ***Resolvendo ciclos de referência fortes entre instâncias de classe***.*
<!-- toc -->

## O que é ARC?

Já sabemos que o Swift nos ajuda em tudo o que é possível. Quando o assunto é gerenciamento de memória, estamos nos referindo ao Contador de Referência Automática (ARC - do inglês `Automatic Reference Counting`) para gerenciar o uso da memória do nosso aplicativo e liberar espaço desnecessário automaticamente para evitar vazamento de memória. O ARC libera automaticamente a memória usada pelas instâncias de classe quando essas não são mais utilizadas, porém, em alguns casos ele não consegue realizar esse gerenciamento e é aí que precisamos dar uma certa atenção para a memória do nosso aplicativo.

## Como o ARC funciona?

Sempre que criamos uma instância de uma classe o ARC aloca um espaço na memória para essa instância. Esse espaço na memória armazena informações sobre o tipo da instância e os valores contidos nela. Mas quando uma instância não é mais necessária o ARC libera esse espaço para que ele possa ser usado em qualquer outra situação e não ocupe espaço desnecessário da memória do nosso dispositivo.

Para garantir que uma instância de classe não desapareça mesmo sendo necessária, o ARC rastreia todos os atributos que podem estar referindo essa instância de classe para que ela não seja desalocada. Enquanto uma instância estiver com referência ativa o ARC não irá desalocar esse espaço na memória.

Isso só é possível acontecer porque quando atribuímos uma instância a uma variável, constante ou propriedade, é criada uma referência forte à instância da classe. Essa referência é chamada de referência "forte"  (`strong`) porque enquanto essa referência permanecer ativa ela não será desalocada da memória.

## ARC na prática

Vamos criar uma classe simples para exemplificar chamada `Pessoa` que define uma constante chamada `nome`:

```swift
class Pessoa {
    let nome: String

    init(nome: String) {
        self.nome = nome
        print("Instância \(nome) foi alocada.")
    }

    deinit{
        print("Instância \(nome) foi desalocada.")
    }
}
```

Como podemos visualizar, essa classe possui um inicializador, que define a constante `nome`, e um desinicializador imprimindo uma mensagem quando a classe é alocada e desalocada.

Agora vamos declarar variáveis para receber referências de instâncias do tipo `Pessoa`:

```swift
var referencia1: Pessoa? // nil
var referencia2: Pessoa? // nil
var referencia3: Pessoa? // nil
```

As variáveis que criamos ainda não fazem referência a nenhuma instância. Então, vamos criar uma instância do tipo `Pessoa` e atribuir a uma das variáveis que acabamos de criar:

```swift
referencia1 = Pessoa(nome: "José da Silva")
// Print: "Instância José da Silva foi alocada."
```

Nesse momento será impresso na tela "Instância José da Silva foi alocada." porque chamamos o construtor de `Pessoa` confirmando que a inicialização aconteceu.

Agora existe uma refereência forte para a instância de `Pessoa` atribuída a `referencia1`, portanto o ARC vai garantir que essa instância permaneça na memória enquanto essa referência existir.

Se atribuirmos a mesma instância de `Pessoa` a mais duas variáveis, teremos 3 referências fortes para a mesma instância.

```swift
referencia2 = referencia1
referencia3 = referencia1
```

Se quebrarmos dois dessas referências, incluindo a referencia original, ainda terá uma referência forte e a instância não será desalocada.

```swift
referencia1 = nil
referencia3 = nil
```

Se quebrarmos a última referência para a instância o ARC irá desalocar o espaço que foi alocado anteriormente na memória.

```swift
referencia2 = nil
// Print: "Instância José da Silva foi desalocada."
```

## Ciclos de Referência Forte (Strong) entre instâncias de classe

No exemplo acima o ARC conseguiu rastrear todas as referências à instância de `Pessoa` e desalocou quando não havia mais nenhuma referência ativa.

No entanto, há casos em que o ARC não consegue desalocar a memória ocupada por instâncias caso uma instância referencie uma a outra, mantendo-as sempre ativas e ela nunca terá um número zero de instancias ativas.

Para solucionar esse problema podemos definir alguns dos relacionamentos entre classes como referência fraca (`weak`) ou não proprietária (`unowned`), em vez de fortes.

## Como o ciclo de referência forte é causado

Abaixo segue um exemplo de como um ciclo de referência pode ser causado acidentalmente.

```swift
class Pessoa {
    let nome: String
    var apartamento: Apartamento?

    init(nome: String) {
        self.nome = nome
    }

    deinit{
        print("Instância \(nome) foi desalocada.")
    }
}

class Apartamento {
    let unidade: Int
    var inquilino: String?

    init(unidade: String) {
        self.unidade = unidade
    }

    deinit {
        print("Instância \(unidade) foi desalocada.")
    }
}
```

A classe `Pessoa` possui uma variável chamada `apartamento` que referencia uma instância de `Apartamento` e a classe `Apartamento` possui uma variável chamada `inquilino` que referencia uma instância de `Pessoa`, ambas são opcionais pois um inquilino pode não ter um apartamento e um apartamento pode não ter um inquilino.

Agora vamos declarar duas variáveis, uma para `Pessoa` e uma para `Apartamento`, ambas opcionais com valor inicial `nil`.

```swift
var jose: Pessoa?
var apt401: Apartamento?
```

Em seguida vamos criar instâncias para `Pessoa` e `Apartamento` e atribuir referências às variáveis.

```swift
jose = Pessoa(nome: "José da Silva")
apt401 = Apartamento(unidade: 401)
```

Agora a variável `jose` tem uma forte referência para a nova instância de `Pessoa` e a variável `apt401` tem uma forte referência para a nova instância de `Apartamento`.

<img width="100%" alt="Imagem com representação da referência forte entre a variável e a instância da classe." src="/images/2019/10/weak-strong-unowned/img1.png" />

Vamos agora vincular os objetos para que uma pessoa tenha um apartamento e um apartamento tenha uma pessoa.

```swift
jose!.apartamento = apt401
apt401!.inquilino = jose
```

Veja como as referências fortes entre os objetos são criadas:

<img width="100%" alt="Imagem ilustração do relacionamento forte entre os objetos." src="/images/2019/10/weak-strong-unowned/img2.png" />

O problema nesse exemplo é que criamos um ciclo de referência em que a instância de `Pessoa` tem uma forte referência para a instância de `Apartamento` e `Apartamento` tem uma forte referência para a instância de `Pessoa`. Com isso o contator de refereência nunca cairá para zero, fazendo quando quebramos as referências e as instâncias nunca serão desalocadas:

```swift
jose!.apartamento = nil
apt401!.inquilino = nil
```

Observe que nenhum desinicializador foi chamado quando definimos as variáveis como `nil`, pois o forte ciclo de refereência impede que as instâncias de `Pessoa` e `Apartametno` sejam desalocadas e as duas continuam alocadas, causando um vazamento de memória, ou seja, as referências nunca poderão ser quebradas.

<img width="100%" alt="Imagem ilustração do forte ciclo de referência entre as instâncias." src="/images/2019/10/weak-strong-unowned/img3.png"/>

## Resolvendo ciclos de referência fortes entre instâncias de classe

Existem duas maneiras de resolver o problema de ciclos de referência forte no swift: **Referências Fracas** e **Referências Não Proprietárias**.

É indicado usar a **Referência Fraca** quando o tempo de vida da instância é curto, ou seja, quando em algum momento ela vai deixar de existir. Já a **Referência Não Proprietária** é indicada quando o tempo de vida da instância é igual ou mais longo que o tempo de vida da instância que possui a referência. Ambas são usadas para evitar o ciclo de referência forte e informar ao ARC que essa instância pode ser desalocada quando não houver referências a ela.

### Referências Fracas (Weak)

Uma referencia fraca é uma referência que não possui uma presença forte na instância a que se refere, dessa forma, não impede que o ARC descarte essa instância e impedindo que essa referência crie um ciclo de referência forte. Para indicar uma variável como referência fraca utilizamos a palavra-chave `weak` antes da variável.

Quando o ARC desaloca a instância que está sendo referenciada automaticamente define o valor da variável para `nil`, portanto, precisa ser sempre declarada como `var` e como opcional para que, em tempo de execução, o ARC possa definir o novo valor à variável.

Agora vamos usar o nosso exemplo das classes `Pessoa` e `Apartamento` e realizar uma alteração simples mas que vai resolver o problema do ciclo de referência forte. Vamos indicar que a variável `inquilino` da classe `Apartamento` é uma referência fraca:

```swift
class Pessoa {
    let nome: String
    var apartamento: Apartamento?

    init(nome: String) {
        self.nome = nome
    }

    deinit{
        print("Instância \(nome) foi desalocada.")
    }
}

class Apartamento {
    let unidade: Int
    weak var inquilino: String?

    init(unidade: String) {
        self.unidade = unidade
    }

    deinit {
        print("Instância \(unidade) foi desalocada.")
    }
}
```

Agora vamos criar as referências fortes entre as variáveis `jose` e `apt401` e os links entre as instâncias como fizemos anteriormente:

```swift
var jose: Pessoa?
var apt401: Apartamento?

jose = Pessoa(nome: "José da Silva")
apt401 = Apartamento(unidade: 401)

jose!.apartamento = apt401
apt401!.inquilino = jose
```

Veja como ficaram as referências:

<img width="100%" alt="Imagem ilustração da referência fraca entre as instâncias." src="/images/2019/10/weak-strong-unowned/img4.png" />

A instância de `Pessoa` ainda possui uma referência forte à instância de `Apartamento`, mas a instância de `Apartamento` possui uma referência fraca para a instância de `Pessoa`. Portanto, se quebrarmos a referência forte mantida pela instância de `jose`, definindo o seu valor para `nil`, não há mais referência forte para instância de `Pessoa`:

```swift
jose = nil
// Print "Instância José da Silva foi desalocada."
```

Como não há mais referência forte para a instância de `Pessoa`, ela é desalocada e a variável `inquilino` da instância de `Apartamento` é definida como `nil`:

<img width="100%" alt="Imagem ilustração da referência forte quebrada e a instância jose desalocada." src="/images/2019/10/weak-strong-unowned/img5.png" />

A única referência forte para a instância de `Apartamento` é a variável `apt401`. Se quebrarmos essa referência forte não haverá mais referência forte para a instância de `Apartamento`:

```swift
apt401 = nil
// Print "Instância 401 foi desalocada."
```

Agora que não há mais referência forte para a instância de `Apartamento` ela também é desalocada:

<img width="100%" alt="Imagem ilustração da referência forte quebrada e a instância apt401 desalocada." src="/images/2019/10/weak-strong-unowned/img6.png" />

### Referências Não Proprietárias (Unowned)
Continua...

Fonte: [Automatic Reference Counting - The swift programming language
(Swift 5.1)](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html)
