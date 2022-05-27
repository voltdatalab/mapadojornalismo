---
layout: page
---

## Como este mapa foi feito

Para construir o Mapa do Jornalismo Local, selecionamos jovens pesquisadoras, comunicadoras e moradoras de territórios periféricos para levantarem dados de veículos jornalísticos e de difusão cultural existentes nas bordas dos 39 municípios da região metropolitana e de São Paulo, nosso primeiro levantamento.

Também tivemos o apoio da equipe interna da Énois e dos parceiros do Volt Data Lab na parte de desenvolvimento e programação.

{% for pessoa in site.data.equipe %}
<br>
#### {{ pessoa.nome }} <span style="font-weight:300;font-size:0.8em"> | <em>{{ pessoa.posicao }}</em></span>
<p>{{ pessoa.desc }}</p>

{% endfor %}

---
## Equipe ÉNóis

{% for pessoa in site.data.equipe_enois %}
<br>
#### {{ pessoa.nome }} <span style="font-weight:300;font-size:0.8em"> | <em>{{ pessoa.posicao }}</em></span>
<p>{{ pessoa.desc }}</p>

{% endfor %}

---
## Equipe Volt Data Lab

{% for pessoa in site.data.equipe_volt %}
<br>
#### {{ pessoa.nome }} <span style="font-weight:300;font-size:0.8em"> | <em>{{ pessoa.posicao }}</em></span>
<p>{{ pessoa.desc }}</p>

{% endfor %}
