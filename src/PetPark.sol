// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract PetPark {

    address public owner;
    constructor() {
        // Set the transaction sender as the owner of the contract.
        owner = msg.sender;
    }

    // Modifier to check that the caller is the owner of
    // the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct Callers {
        Gender gender;
        uint8 age;
    }

    mapping(AnimalType => uint256) public animalCounts;
    mapping(address => AnimalType) borrowedList;
    mapping(address => Callers) calledList;

    event Added(AnimalType indexed _animalType, uint256 _count);
    event Borrowed(AnimalType indexed _animalType);
    event Returned(AnimalType indexed _animalType);

    function add(AnimalType _animalType, uint256 _count) external onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");
        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) external {
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        require(_age > 0, "Age is 0");

        // Address hasn't called before
        if (calledList[msg.sender].age == 0) {
            calledList[msg.sender].age = _age;
            calledList[msg.sender].gender = _gender;
        }
        else {
            require(calledList[msg.sender].age == _age, "Invalid Age");
            require(calledList[msg.sender].gender == _gender, "Invalid Gender");
        }

        require(borrowedList[msg.sender] == AnimalType.None, "Already adopted a pet");

        if (_gender == Gender.Male){
            require((_animalType == AnimalType.Dog || _animalType == AnimalType.Fish), "Invalid animal for men");
        }
        else {
            require((_age > 40 && _animalType == AnimalType.Cat), "Invalid animal for women under 40");
        }


        borrowedList[msg.sender] = _animalType;
        animalCounts[_animalType] -=1;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        require(borrowedList[msg.sender] != AnimalType.None, "No borrowed pets");
        AnimalType _borrowedAnimalType = borrowedList[msg.sender];
        borrowedList[msg.sender] = AnimalType.None;
        animalCounts[_borrowedAnimalType] +=1;
        emit Returned(_borrowedAnimalType);
    }
    
}