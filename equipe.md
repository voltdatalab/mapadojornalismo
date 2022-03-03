---
layout: page
---

## Conheça quem faz o Mapa de Jornalismo Local

{% for pessoa in site.data.equipe %}
<br>
#### {{ pessoa.nome }} <span style="font-weight:300;font-size:0.8em"> | <em>{{ pessoa.posicao }}</em></span>
<p>{{ pessoa.desc }}</p>

{% endfor %}
