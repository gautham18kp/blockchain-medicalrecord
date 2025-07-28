// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MedicalRecords {
    struct File {
        string fileHash;
        uint256 timestamp;
    }

    struct AccessRequest {
        address doctor;
        bool approved;
        bool exists;
    }

    mapping(address => File[]) private patientFiles;
    mapping(address => mapping(address => AccessRequest)) public accessRequests;
    mapping(address => address[]) private approvedDoctors;

    event FileUploaded(address indexed patient, string fileHash, uint256 timestamp);
    event AccessRequested(address indexed doctor, address indexed patient);
    event AccessApproved(address indexed patient, address indexed doctor);
    event AccessRevoked(address indexed patient, address indexed doctor);
    event AccessRejected(address indexed patient, address indexed doctor);

    // Patient uploads a medical file
    function uploadFile(string memory _fileHash) public {
        patientFiles[msg.sender].push(File(_fileHash, block.timestamp));
        emit FileUploaded(msg.sender, _fileHash, block.timestamp);
    }

    // Doctor requests access to a patient's records
    function requestAccess(address _patient) public {
        require(_patient != msg.sender, "You cannot request access to your own records");
        require(!accessRequests[_patient][msg.sender].exists, "Request already exists");

        accessRequests[_patient][msg.sender] = AccessRequest(msg.sender, false, true);
        emit AccessRequested(msg.sender, _patient);
    }

    // Patient approves a doctor's request
    function approveAccess(address _doctor) public {
        require(accessRequests[msg.sender][_doctor].exists, "No access request found");
        require(!accessRequests[msg.sender][_doctor].approved, "Access already granted");

        accessRequests[msg.sender][_doctor].approved = true;
        approvedDoctors[msg.sender].push(_doctor);
        emit AccessApproved(msg.sender, _doctor);
    }

    // Patient rejects a doctor's request
    function rejectAccess(address _doctor) public {
        require(accessRequests[msg.sender][_doctor].exists, "No access request found");
        require(!accessRequests[msg.sender][_doctor].approved, "Access already rejected");

        delete accessRequests[msg.sender][_doctor];
        emit AccessRejected(msg.sender, _doctor);
    }

    // Patient revokes access from a doctor
    function revokeAccess(address _doctor) public {
        require(accessRequests[msg.sender][_doctor].approved, "Access not granted");

        accessRequests[msg.sender][_doctor].approved = false;
        emit AccessRevoked(msg.sender, _doctor);
    }

    // Doctor retrieves the patient's files (if access is approved)
    function getFiles(address _patient) public view returns (File[] memory) {
        require(accessRequests[_patient][msg.sender].approved, "Access denied");
        return patientFiles[_patient];
    }

    // Get all approved doctors for a patient
    function getApprovedDoctors() public view returns (address[] memory) {
        return approvedDoctors[msg.sender];
    }

    // Check if a doctor has requested access
    function checkAccessRequest(address _doctor) public view returns (bool) {
        return accessRequests[msg.sender][_doctor].exists;
    }
}
