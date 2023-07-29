//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts@4.2.0/access/Ownable.sol";

contract PetPark is Ownable {

    enum AnimalType {
        Null,
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

    mapping(AnimalType => uint256) currentAnimalsInPark;
    mapping(address => AnimalType) borrowedList;
    mapping(address => Callers) calledList;

    event Added(AnimalType indexed _animalType, uint256 _count);
    event Borrowed(AnimalType indexed _animalType);
    event Returned(AnimalType indexed _animalType);

    function add(AnimalType _animalType, uint256 _count) external onlyOwner {
        require(_animalType != AnimalType.Null, "Animal provided is invalid");
        currentAnimalsInPark[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) external {
        require(_animalType != AnimalType.Null, "Animal provided is invalid");
        require(borrowedList[msg.sender] == AnimalType.Null, "Already borrowed an animal, return it to borrow another one.");
        require(currentAnimalsInPark[_animalType] > 0, "No animals of the specified type are in the park currently for borrowing.");
        require(_age > 0, "Come on, this can't be right. Age is seriously 0?");

        // Address hasn't called before
        if (calledList[msg.sender].age == 0) {
            calledList[msg.sender].age = _age;
            calledList[msg.sender].gender = _gender;
        }
        else {
            require(calledList[msg.sender].age == _age, "Caller's age doesn't match the original caller.");
            require(calledList[msg.sender].gender == _gender, "Caller's gender doesn't match the original caller.");
        }

        if (_gender == Gender.Male){
            require((_animalType == AnimalType.Dog || _animalType == AnimalType.Fish), "Men can only borrow Dog or Fish");
        }
        else {
            require((_age < 40 && _animalType == AnimalType.Cat), "Women under age of 40 cannot borrow Cats");
        }

        borrowedList[msg.sender] = _animalType;
        currentAnimalsInPark[_animalType] -=1;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        require(borrowedList[msg.sender] != AnimalType.Null, "You haven't borrowed any animal to return.");
        AnimalType _borrowedAnimalType = borrowedList[msg.sender];
        borrowedList[msg.sender] = AnimalType.Null;
        currentAnimalsInPark[_borrowedAnimalType] +=1;
        emit Returned(_borrowedAnimalType);
    }
    
}
