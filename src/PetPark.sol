// SPDX-License-Identifier: GPL-3.0

// Solidity version
pragma solidity ^0.8.13;

// Contract definition
contract PetPark {

    // State variable to store the contract owner's address
    address public owner;

    // Constructor function to initialize contract and set the owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to check that the caller is the owner of
    // the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // Enum type to define different animals
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    // Enum type to define different genders
    enum Gender {
        Male,
        Female
    }

    // Struct type to store information about callers
    struct Callers {
        Gender gender;
        uint8 age;
    }

    // Mapping to store the count of each animal type
    mapping(AnimalType => uint256) public animalCounts;

    // Mapping to store the type of animal borrowed by each address
    mapping(address => AnimalType) borrowedList;

    // Mapping to store the information of each caller
    mapping(address => Callers) calledList;

    // Events
    event Added(AnimalType indexed _animalType, uint256 _count);
    event Borrowed(AnimalType indexed _animalType);
    event Returned(AnimalType indexed _animalType);

    // Function to add animals of a specific type
    function add(AnimalType _animalType, uint256 _count) external onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");
        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    // Function to borrow an animal
    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) external {
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        require(_age > 0, "Age is 0");

        // Check if the address has borrowed before
        if (calledList[msg.sender].age == 0) {
            calledList[msg.sender].age = _age;
            calledList[msg.sender].gender = _gender;
        } else {
            require(calledList[msg.sender].age == _age, "Invalid Age");
            require(calledList[msg.sender].gender == _gender, "Invalid Gender");
        }

        require(borrowedList[msg.sender] == AnimalType.None, "Already adopted a pet");

        // Check animal eligibility based on gender
        if (_gender == Gender.Male) {
            require((_animalType == AnimalType.Dog || _animalType == AnimalType.Fish), "Invalid animal for men");
        } else {
            require((_age > 40 && _animalType == AnimalType.Cat), "Invalid animal for women under 40");
        }

        borrowedList[msg.sender] = _animalType;
        animalCounts[_animalType] -= 1;
        emit Borrowed(_animalType);
    }

    // Function to return borrowed animal
    function giveBackAnimal() external {
        require(borrowedList[msg.sender] != AnimalType.None, "No borrowed pets");
        AnimalType _borrowedAnimalType = borrowedList[msg.sender];
        borrowedList[msg.sender] = AnimalType.None;
        animalCounts[_borrowedAnimalType] += 1;
        emit Returned(_borrowedAnimalType);
    }
    
}
