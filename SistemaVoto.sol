// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;
/**
    * @title Sistema de Votacion descentralizado
    * @notice Este contrato permite la gestión de un sistema de votación con registro de votantes, candidatos y votación.
 */
contract VotingSystem {
    // Rol de administrador
    address public immutable admin;
    
    // Fases electorales
    enum ElectionPhase { Registration, Voting, Ended }
    ElectionPhase public currentPhase;
    
    // Estructura para candidatos
    struct Candidate {
        string name;
        uint256 voteCount;
    }
    
    // Estructura para votantes
    struct Voter {
        bool isAuthorized;
        bool hasVoted;
        address delegate;
        uint256 weight;           
        uint256 votedCandidateId; 
    }
    
    // Mappings y almacenamiento
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    uint256 public candidateCount;
    
    // Eventos importantes
    event VoterRegistered(address voter);
    event CandidateAdded(uint256 id, string name);
    event VoteCast(address voter, uint256 candidateId);
    event ElectionPhaseChanged(ElectionPhase newPhase);
    event VoteDelegated(address from, address to);

    // Modificador para funciones exclusivas del admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Solo el administrador puede ejecutar esta funcion");
        _;
    }
    
    // Modificador para control de fases
    modifier onlyInPhase(ElectionPhase phase) {
        require(currentPhase == phase, "Operacion no permitida en esta fase");
        _;
    }
    
    /**
     * @dev Constructor del contrato. Establece al administrador y la fase inicial.
     */
    constructor() {
        admin = msg.sender;
        currentPhase = ElectionPhase.Registration;
    }

    /**
     * @notice Inicia la fase de votación.
     * @dev Solo el administrador puede llamar durante la fase de registro.
     */
    function startVotingPhase() external onlyAdmin onlyInPhase(ElectionPhase.Registration) {
        currentPhase = ElectionPhase.Voting;
        emit ElectionPhaseChanged(currentPhase);
    }

    /**
     * @notice Finaliza la elección.
     * @dev Solo el administrador puede llamar durante la fase de votación.
     */
    function endElection() external onlyAdmin onlyInPhase(ElectionPhase.Voting) {
        currentPhase = ElectionPhase.Ended;
        emit ElectionPhaseChanged(currentPhase);
    }

    /**
     * @notice Agrega un nuevo candidato.
     * @dev Solo el administrador puede llamar durante la fase de registro.
     * @param _name Nombre del candidato.
     */
    function addCandidate(string memory _name) 
        external 
        onlyAdmin 
        onlyInPhase(ElectionPhase.Registration) 
    {
        candidates[++candidateCount] = Candidate(_name, 0);
        emit CandidateAdded(candidateCount, _name);
    }

    /**
     * @notice Devuelve la lista de todos los candidatos registrados.
     * @return ids Array con los IDs de los candidatos.
     * @return names Array con los nombres de los candidatos.
     * @return votes Array con la cantidad de votos de cada candidato.
     */
    function getCandidates()
        external
        view
        returns (
            uint256[] memory ids,
            string[] memory names,
            uint256[] memory votes
        )
    {
        ids = new uint256[](candidateCount);
        names = new string[](candidateCount);
        votes = new uint256[](candidateCount);

        for (uint256 i = 0; i < candidateCount; i++) {
            uint256 id = i + 1;
            ids[i] = id;
            names[i] = candidates[id].name;
            votes[i] = candidates[id].voteCount;
        }
    }

    /**
     * @notice Devuelve la fase actual de la elección como cadena.
     * @return faseActual Cadena con el estado actual de la votación.
     */
    function getCurrentPhase() external view returns (string memory faseActual) {
        if (currentPhase == ElectionPhase.Registration) {
            return "Etapa de registro";
        } else if (currentPhase == ElectionPhase.Voting) {
            return "Etapa de voto";
        } else {
            return "Votacion Finalizada";
        }
    }

    /**
     * @notice Registra un nuevo votante.
     * @dev Solo el administrador puede llamar durante la fase de registro.
     * @param _voter Dirección del votante a registrar.
     */
    function registerVoter(address _voter) 
        external 
        onlyAdmin 
        onlyInPhase(ElectionPhase.Registration) 
    {
        require(!voters[_voter].isAuthorized, "Votante ya registrado");
        voters[_voter] = Voter(true, false, address(0), 1, 0); // Peso inicial 1
        emit VoterRegistered(_voter);
    }

    /**
     * @notice Permite a un votante emitir su voto.
     * @dev Solo durante la fase de votación.
     * @param _candidateId ID del candidato a votar.
     */
    function vote(uint256 _candidateId) 
        external 
        onlyInPhase(ElectionPhase.Voting) 
    {
        require(voters[msg.sender].isAuthorized, "No autorizado a votar");
        require(!voters[msg.sender].hasVoted, "Ya has votado");
        require(_candidateId > 0 && _candidateId <= candidateCount, "Candidato invalido");
        
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId; // Guardar candidato votado
        candidates[_candidateId].voteCount += voters[msg.sender].weight; // Sumar peso
        emit VoteCast(msg.sender, _candidateId);
    }

    /**
     * @notice Permite delegar el voto a otro votante.
     * @dev Solo durante la fase de votación. Previene delegación circular.
     * @param _to Dirección del votante al que se delega el voto.
     */
    function delegateVote(address _to) external onlyInPhase(ElectionPhase.Voting) {
        require(voters[msg.sender].isAuthorized, "No estas autorizado a votar");
        require(!voters[msg.sender].hasVoted, "Ya has votado");
        require(voters[_to].isAuthorized, "El delegado no esta autorizado a votar");
        require(_to != msg.sender, "No puedes delegar tu voto a ti mismo");
        require(voters[msg.sender].delegate == address(0), "Ya has delegado tu voto");

        address delegate = _to;
        while (voters[delegate].delegate != address(0)) {
            delegate = voters[delegate].delegate;
            require(delegate != msg.sender, "Delegacion circular detectada");
        }

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].delegate = delegate;

        if (voters[delegate].hasVoted) {
            // Si el delegado ya votó, suma el peso del delegante al candidato elegido por el delegado
            uint256 candidateId = voters[delegate].votedCandidateId;
            require(candidateId > 0, "El delegado no ha votado por ningun candidato");
            candidates[candidateId].voteCount += voters[msg.sender].weight;
        } else {
            // Si el delegado no ha votado, suma el peso del delegante al peso del delegado
            voters[delegate].weight += voters[msg.sender].weight;
        }

        emit VoteDelegated(msg.sender, delegate);
    }

    /**
     * @notice Obtiene el candidato ganador.
     * @dev Solo puede llamarse cuando la elección ha terminado.
     * @return winnerId ID del candidato ganador.
     * @return winnerName Nombre del candidato ganador.
     */
    function getWinner() 
        external 
        view 
        onlyInPhase(ElectionPhase.Ended) 
        returns (uint256 winnerId, string memory winnerName) 
    {
        uint256 winningVoteCount = 0;
        winnerId = 0;
        winnerName = "";

        for (uint256 i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winnerId = i;
                winnerName = candidates[i].name;
            }
        }
    }
}