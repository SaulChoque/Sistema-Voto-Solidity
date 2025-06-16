# Sistema de Votación Descentralizado - Smart Contract

Este proyecto implementa un contrato inteligente en Solidity para gestionar un sistema de votación descentralizado. Permite el registro de votantes y candidatos, la emisión de votos, la delegación de votos y la obtención de resultados de manera transparente y segura.

## Características principales

- **✅ Fases de la elección:**  
  - Registro de votantes y candidatos  
  - Votación  
  - Finalización y consulta de resultados

- **🙍‍♂️ Roles:**  
  - Solo el administrador (quien despliega el contrato) puede registrar votantes y candidatos, y cambiar de fase.

- **🙍‍♂️🙍‍♀️ Delegación de voto:**  
  - Los votantes pueden delegar su voto a otro votante autorizado.

- **👻 Transparencia:**  
  - Cualquier usuario puede consultar la lista de candidatos, la fase actual y el ganador al finalizar la elección.

##📋 Descripción de las funciones principales

- `addCandidate(string memory _name)`  
  Registra un nuevo candidato. Solo el administrador puede ejecutarla durante la fase de registro.

- `registerVoter(address _voter)`  
  Registra un nuevo votante. Solo el administrador puede ejecutarla durante la fase de registro.

- `startVotingPhase()`  
  Cambia la fase de la elección de registro a votación. Solo el administrador puede ejecutarla.

- `endElection()`  
  Finaliza la elección y permite consultar el ganador. Solo el administrador puede ejecutarla.

- `vote(uint256 _candidateId)`  
  Permite a un votante autorizado emitir su voto por un candidato durante la fase de votación.

- `delegateVote(address _to)`  
  Permite a un votante autorizado delegar su voto a otro votante durante la fase de votación.

- `getCandidates()`  
  Devuelve la lista de candidatos registrados con sus IDs, nombres y cantidad de votos.

- `getCurrentPhase()`  
  Devuelve la fase actual de la elección como una cadena descriptiva:  
  - "Etapa de registro"  
  - "Etapa de voto"  
  - "Votacion Finalizada"

- `getWinner()`  
  Devuelve el ID y nombre del candidato ganador. Solo puede llamarse cuando la elección ha finalizado.

##🖥️ Ejemplo de flujo de uso

1. **Despliegue:**  
   El administrador despliega el contrato.

2. **Registro:**  
   El administrador registra candidatos y votantes usando `addCandidate` y `registerVoter`.

3. **Inicio de votación:**  
   El administrador llama a `startVotingPhase()` para comenzar la votación.

4. **Votación:**  
   Los votantes emiten su voto con `vote` o delegan su voto con `delegateVote`.

5. **Finalización:**  
   El administrador llama a `endElection()` para finalizar la elección.

6. **Resultados:**  
   Cualquier usuario puede consultar el ganador con `getWinner()` y la lista de candidatos con `getCandidates()`.

##📋 Requisitos

- Solidity ^0.8.0
- Herramienta de despliegue y pruebas (Remix, Hardhat, Truffle, etc.)

##🔏 Seguridad

- Solo el administrador puede registrar candidatos y votantes, y cambiar de fase.
- No se permite votar más de una vez ni delegar el voto más de una vez.
- Se previene la delegación circular de votos.

---

**Autor:** Saul Mijael Choquehuanca Huanca
**Licencia:** MIT
