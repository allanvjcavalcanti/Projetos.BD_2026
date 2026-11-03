#!/usr/bin/env bash
# Cria um repositório no GitHub para cada pasta e envia o conteúdo.
# Precisa do git e do GitHub CLI (gh) logado.
set -e

publicar() {
  pasta=$1; repo=$2; desc=$3
  echo "Publicando $pasta -> $repo"
  (
    cd "$pasta"
    [ -d .git ] || git init -q
    git add .
    git commit -q -m "primeiro commit" || true
    git branch -M main
    gh repo create "$repo" --public --description "$desc" --source=. --remote=origin --push
  )
}

publicar 01-sql-vs-nosql        sql-vs-nosql-engenharia-de-dados "SQL e NoSQL para engenharia de dados"
publicar 02-ecommerce-logico    ecommerce-projeto-logico-bd      "Projeto lógico de banco de dados de e-commerce (MySQL)"
publicar 03-oficina-logico      oficina-projeto-logico-bd        "Projeto lógico de banco de dados de oficina mecânica (MySQL)"
publicar 04-oficina-conceitual  oficina-modelo-conceitual        "Modelo conceitual de oficina mecânica"
publicar 05-ecommerce-conceitual ecommerce-modelo-conceitual     "Modelo conceitual refinado de e-commerce"

echo "Pronto: https://github.com/allanvjcavalcanti?tab=repositories"
