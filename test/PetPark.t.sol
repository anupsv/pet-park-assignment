// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PetPark.sol";


contract PetParkTest is Test, PetPark {
    PetPark petPark;
    
    address testOwnerAccount;

    address testPrimaryAccount;
    address testSecondaryAccount;

    function setUp() public {
        petPark = new PetPark();

        testOwnerAccount = msg.sender;
        testPrimaryAccount = address(0xABCD);
        testSecondaryAccount = address(0xABDC);
    }

    function testOwnerCanAddAnimal() public {
        petPark.add(AnimalType.Fish, 5);
    }

    function testCannotAddAnimalWhenNonOwner() public {
        uint dogOriginalPetCount = petPark.animalCounts(AnimalType.Dog);
        petPark.add(AnimalType.Dog, 2);
        uint dogPetCountAfterAdd = petPark.animalCounts(AnimalType.Dog);
        assertEq(dogOriginalPetCount +2, dogPetCountAfterAdd);

        vm.expectRevert("Not owner");
        vm.prank(testSecondaryAccount);
        petPark.add(AnimalType.Dog, 2);
    }

    function testCannotAddInvalidAnimal() public {
        vm.expectRevert("Invalid animal");
        petPark.add(AnimalType.None, 5);
    }

    function testExpectEmitAddEvent() public {
        vm.expectEmit(false, false, false, true);

        emit Added(AnimalType.Fish, 5);
        petPark.add(AnimalType.Fish, 5);
    }

    function testCannotBorrowWhenAgeZero() public {
        petPark.add(AnimalType.Fish, 1);

        vm.expectRevert("Age is 0");
        petPark.borrow(0, Gender.Male, AnimalType.Fish);

        vm.expectRevert("Age is 0");
        petPark.borrow(0, Gender.Female, AnimalType.Fish);
    }

    function testCannotBorrowUnavailableAnimal() public {
        vm.expectRevert("Selected animal not available");

        petPark.borrow(24, Gender.Male, AnimalType.Fish);
    }

    function testCannotBorrowInvalidAnimal() public {
        vm.expectRevert("Invalid animal type");

        petPark.borrow(24, Gender.Male, AnimalType.None);
    }

    function testCannotBorrowCatForMen() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, Gender.Male, AnimalType.Cat);
    }

    function testCannotBorrowRabbitForMen() public {
        petPark.add(AnimalType.Rabbit, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, Gender.Male, AnimalType.Rabbit);
    }

    function testCannotBorrowParrotForMen() public {
        petPark.add(AnimalType.Parrot, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, Gender.Male, AnimalType.Parrot);
    }

    function testCannotBorrowForWomenUnder40() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Invalid animal for women under 40");
        petPark.borrow(24, Gender.Female, AnimalType.Cat);
    }

    function testCannotBorrowTwiceAtSameTime() public {
        petPark.add(AnimalType.Fish, 5);
        petPark.add(AnimalType.Cat, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

        vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Cat);
    }

    function testCannotBorrowWhenAddressDetailsAreDifferent() public {
        petPark.add(AnimalType.Fish, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Invalid Age");
        vm.prank(testPrimaryAccount);
        petPark.borrow(23, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Invalid Gender");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Female, AnimalType.Fish);
    }

    function testExpectEmitOnBorrow() public {
        petPark.add(AnimalType.Fish, 5);
        vm.expectEmit(false, false, false, true);

        emit Borrowed(AnimalType.Fish);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);
    }

    function testBorrowCountDecrement() public {
        petPark.add(AnimalType.Dog, 1);
        petPark.add(AnimalType.Fish, 2);
        uint dogOriginalPetCount = petPark.animalCounts(AnimalType.Dog);
        uint fishOriginalPetCount = petPark.animalCounts(AnimalType.Fish);
        petPark.borrow(24, Gender.Male, AnimalType.Dog);
        uint dogPetCountAfterBorrow = petPark.animalCounts(AnimalType.Dog);
        uint fishPetCountAfterBorrow = petPark.animalCounts(AnimalType.Fish);

        assertEq(dogOriginalPetCount, dogPetCountAfterBorrow + 1);
        assertEq(fishOriginalPetCount, fishPetCountAfterBorrow);
    }

    function testCannotGiveBack() public {
        vm.expectRevert("No borrowed pets");
        petPark.giveBackAnimal();
    }

    function testPetCountIncrement() public {
        petPark.add(AnimalType.Fish, 5);

        petPark.borrow(24, Gender.Male, AnimalType.Fish);
        uint reducedPetCount = petPark.animalCounts(AnimalType.Fish);

        petPark.giveBackAnimal();
        uint currentPetCount = petPark.animalCounts(AnimalType.Fish);

		assertEq(reducedPetCount, currentPetCount - 1);
    }
}