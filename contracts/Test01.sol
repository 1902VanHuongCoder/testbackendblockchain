// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;  

contract Test01 {  
    // Sử dụng enum cho trạng thái sản phẩm  
    enum ProductStatus { Planted, Harvested, Delivered, Received, Completed }  
    
    // Cấu trúc dữ liệu lưu thông tin của nông sản  
    struct Product {  
        uint256 productId;  
        string productName;  
        string imageHash;  
        string plantingDate;  
        string harvestDate;  
        string farmerName;  
        string distributorName;  
        string retailerName;  
        uint256 productWeight;  
        ProductStatus status;  
    }  

    // Cấu trúc dữ liệu cho người dùng  
    struct User {  
        string userName;  
        string role; // "farmer", "distributor", "retailer", "consumer"  
        bool isRegistered;  
    }  

    // Mapping từ productId đến sản phẩm  
    mapping(uint256 => Product) public products;  

    // Mapping từ địa chỉ người dùng đến thông tin người dùng  
    mapping(address => User) public users;  

    function getUserInfo(address _userAddress) public view returns (string memory, string memory) {  
        User memory user = users[_userAddress];  
        require(user.isRegistered, "User not registered.");  
        return (user.userName, user.role);  
    }  

    // Sự kiện  
    event FarmerRegistered(address farmer, string farmerName);  
    event ProductAdded(uint256 productId, string productName);  
    event ProductUpdated(uint256 productId, string updatedBy);  

    // Đăng ký tài khoản cho người dùng (Farmer, Distributor, Retailer, Consumer)  
    function registerUser(string memory _userName, string memory _role) public {  
        require(!users[msg.sender].isRegistered, "User already registered.");   
        require(  
            keccak256(abi.encodePacked(_role)) == keccak256("farmer") ||  
            keccak256(abi.encodePacked(_role)) == keccak256("distributor") ||  
            keccak256(abi.encodePacked(_role)) == keccak256("retailer") ||  
            keccak256(abi.encodePacked(_role)) == keccak256("consumer"),  
            "Invalid role."  
        );  

        users[msg.sender] = User({  
            userName: _userName,  
            role: _role,  
            isRegistered: true  
        });  

        if (keccak256(abi.encodePacked(_role)) == keccak256("farmer")) {  
            emit FarmerRegistered(msg.sender, _userName);  
        }  
    }  

    // Modifier kiểm tra người dùng đã đăng ký  
    modifier onlyRegistered() {  
        require(users[msg.sender].isRegistered, "User not registered.");  
        _;  
    }  

    // Modifier kiểm tra vai trò người dùng  
    modifier onlyRole(string memory _role) {  
        require(  
            keccak256(abi.encodePacked(users[msg.sender].role)) == keccak256(abi.encodePacked(_role)),   
            string(abi.encodePacked("Only ", _role, "s can perform this action."))  
        );  
        _;  
    }  

    // Kiểm tra nếu productId đã tồn tại  
    function productExists(uint256 _productId) internal view returns (bool) {  
        return products[_productId].productId == _productId;  
    }  

    // Nông dân thêm thông tin nông sản  
    function addProduct(  
        uint256 _productId, // now accepting productId as parameter  
        string memory _imageHash,  
        string memory _productName,  
        string memory _plantingDate,  
        string memory _harvestDate,  
        string memory _farmerName  
    ) public onlyRegistered onlyRole("farmer") {  
        require(!productExists(_productId), "Product ID already exists."); // check if the product ID already exists  

        products[_productId] = Product({  
            productId: _productId,  
            productName: _productName,  
            imageHash: _imageHash,  
            plantingDate: _plantingDate,  
            harvestDate: _harvestDate,  
            farmerName: _farmerName,  
            distributorName: "",  
            retailerName: "",  
            productWeight: 0,  
            status: ProductStatus.Planted  
        });  

        emit ProductAdded(_productId, _productName);  
    }  

    // Nhà phân phối cập nhật thông tin sản phẩm  
    function updateDistributorInfo(  
        uint256 _productId,  
        string memory _distributorName,  
        uint256 _productWeight  
    ) public onlyRegistered onlyRole("distributor") {  
        require(productExists(_productId), "Invalid product ID."); // use the productExists function here  

        Product storage product = products[_productId];  
        product.distributorName = _distributorName;  
        product.productWeight = _productWeight;  
        product.status = ProductStatus.Delivered;  

        emit ProductUpdated(_productId, _distributorName);  
    }  

    // Nhà bán lẻ cập nhật thông tin sản phẩm  
    function updateRetailerInfo(  
        uint256 _productId,  
        string memory _retailerName  
    ) public onlyRegistered onlyRole("retailer") {  
        require(productExists(_productId), "Invalid product ID."); // use the productExists function here  

        Product storage product = products[_productId];  
        product.retailerName = _retailerName;  
        product.status = ProductStatus.Received;  

        emit ProductUpdated(_productId, _retailerName);  
    }  

    // Người tiêu dùng truy xuất nguồn gốc sản phẩm  
    function getProductInfo(uint256 _productId) public view returns (Product memory) {  
        require(productExists(_productId), "Invalid product ID."); // use the productExists function here  
        return products[_productId];  
    }  
}