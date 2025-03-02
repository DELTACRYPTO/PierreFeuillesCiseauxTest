WE ARE BASED#

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DuelEliminatoire {
    address public owner;
    address[4] public participants;
    mapping(address => string) public choixDuel;
    address public gagnant;
    uint public tour = 0;
    bool public jeuActif = true;

    event DuelEngage(address joueur1, address joueur2);
    event GagnantDeclare(address gagnant);
    event JoueurElimine(address joueur);
    event ChoixAttendu(address joueur, string message);
    event JeuTermine(string message);

    constructor() {
        owner = msg.sender;
    }

    // Fonction pour inscrire un joueur
    function participer() public {
        require(jeuActif, "Le jeu est termine.");
        require(!_dejaInscrit(msg.sender), "Vous participez deja.");
        require(tour < 4, "Nombre maximum de joueurs atteint.");

        participants[tour] = msg.sender;
        tour++;
        
        // Si le jeu est prêt à commencer, on notifie les joueurs
        if (tour == 4) {
            emit ChoixAttendu(participants[0], "Tous les joueurs sont inscrits. Faites votre choix: pierre, feuille ou ciseaux.");
            emit ChoixAttendu(participants[1], "Tous les joueurs sont inscrits. Faites votre choix: pierre, feuille ou ciseaux.");
            emit ChoixAttendu(participants[2], "Tous les joueurs sont inscrits. Faites votre choix: pierre, feuille ou ciseaux.");
            emit ChoixAttendu(participants[3], "Tous les joueurs sont inscrits. Faites votre choix: pierre, feuille ou ciseaux.");
        }
    }

    // Fonction pour choisir pierre, feuille ou ciseaux
    function choisirDuel(string memory choix) public {
        require(jeuActif, "Le jeu est termine.");
        require(_dejaInscrit(msg.sender), "Vous devez d'abord vous inscrire.");
        require(_estChoixValide(choix), "Choix invalide. Vous devez choisir entre pierre, feuille ou ciseaux.");
        
        // Enregistrer le choix du joueur
        choixDuel[msg.sender] = choix;

        // Vérifier si tous les joueurs ont fait leur choix
        if (bytes(choixDuel[participants[0]]).length > 0 &&
            bytes(choixDuel[participants[1]]).length > 0 &&
            bytes(choixDuel[participants[2]]).length > 0 &&
            bytes(choixDuel[participants[3]]).length > 0) {
            _resoudreDuels();
        }
    }

    // Résoudre les duels entre les joueurs
    function _resoudreDuels() private {
        // Duel entre le joueur 1 et le joueur 2
        address joueur1 = participants[0];
        address joueur2 = participants[1];
        address perdant1 = _resoudreDuel(joueur1, joueur2);
        emit JoueurElimine(perdant1);

        // Duel entre le joueur 3 et le joueur 4
        address joueur3 = participants[2];
        address joueur4 = participants[3];
        address perdant2 = _resoudreDuel(joueur3, joueur4);
        emit JoueurElimine(perdant2);

        // Gagnants des duels
        address gagnant1 = (perdant1 == joueur1) ? joueur2 : joueur1;
        address gagnant2 = (perdant2 == joueur3) ? joueur4 : joueur3;

        // Duel final entre les 2 gagnants
        address finaliste1 = gagnant1;
        address finaliste2 = gagnant2;

        // Résolution du duel final
        address finalGagnant = _resoudreDuel(finaliste1, finaliste2);
        gagnant = finalGagnant;

        emit GagnantDeclare(gagnant);

        // Fin du jeu
        jeuActif = false;
        emit JeuTermine("Le jeu est termine ! Le gagnant a ete declare.");
    }

    // Résoudre un duel entre 2 joueurs (fonction marquée 'view' car elle lit l'état)
    function _resoudreDuel(address joueur1, address joueur2) private view returns (address) {
        string memory choix1 = choixDuel[joueur1];
        string memory choix2 = choixDuel[joueur2];

        // Conditions de victoire pour chaque choix
        if (keccak256(bytes(choix1)) == keccak256(bytes(choix2))) {
            return address(0); // Match nul
        } else if (
            (keccak256(bytes(choix1)) == keccak256(bytes("pierre")) && keccak256(bytes(choix2)) == keccak256(bytes("ciseaux"))) ||
            (keccak256(bytes(choix1)) == keccak256(bytes("feuille")) && keccak256(bytes(choix2)) == keccak256(bytes("pierre"))) ||
            (keccak256(bytes(choix1)) == keccak256(bytes("ciseaux")) && keccak256(bytes(choix2)) == keccak256(bytes("feuille")))
        ) {
            return joueur2; // Joueur 2 perd
        } else {
            return joueur1; // Joueur 1 perd
        }
    }

    // Vérifier si un joueur a fait un choix valide (pierre, feuille ou ciseaux)
    function _estChoixValide(string memory choix) private pure returns (bool) {
        return (keccak256(bytes(choix)) == keccak256(bytes("pierre")) ||
                keccak256(bytes(choix)) == keccak256(bytes("feuille")) ||
                keccak256(bytes(choix)) == keccak256(bytes("ciseaux")));
    }

    // Vérifier si un joueur est déjà inscrit
    function _dejaInscrit(address joueur) private view returns (bool) {
        for (uint i = 0; i < 4; i++) {
            if (participants[i] == joueur) return true;
        }
        return false;
    }

    // Permet de récupérer les participants
    function getParticipants() public view returns (address[4] memory) {
        return participants;
    }
}

