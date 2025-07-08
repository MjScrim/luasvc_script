# luasvc

Um gerenciador de serviços minimalista escrito em **Lua**, projetado para ser simples, leve e fácil de integrar em sistemas baseados em Unix (como Arch Linux).

> Ideal para setups pessoais, VMs, containers ou ambientes de aprendizado sobre init systems.

---

## Funcionalidades

-  Iniciar, parar e listar serviços
-  Leitura de serviços a partir de arquivos `.service` (estilo systemd)
-  Suporte a dependências entre serviços (`Requires=`)
-  Redirecionamento de logs por serviço (`Log=`)
-  Independente de systemd ou init — roda apenas com Lua + POSIX tools
-  Fácil integração com `/etc/rc.local` para serviços no boot

---

##  Estrutura de serviços

Os serviços são definidos em arquivos `.service`, armazenados em um diretório `services/`. Exemplo:

```ini
[Service]
Name=Example Service
Exec=/usr/bin/sleep 30
Log=/tmp/example.log
Requires=network

