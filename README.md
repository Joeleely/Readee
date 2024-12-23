# Readee
Readee is a mobile application for book swapping, allowing users to exchange books with others in their local community. The app features a frontend built with Flutter and a backend powered by Go.

## Prerequisites
Before you start, make sure you have the following installed:

### Flutter
- Install Flutter by following the official guide: [Flutter Installation Guide](https://docs.flutter.dev/)

### Dart
- Version between **2.12.0** and **3.0.0**.

### Go
- Version **1.22.6** or higher.

### MySQL
- MySQL (v8.0 or higher).

### Configuration
1. **Database Configuration**
   - Replace the **Database URL** in `database.go` (line 23):
     ```go
     dsn2 := "parn:parn1234@tcp(server2.bsthun.com:4004)/poc2?charset=utf8mb4&parseTime=true&loc=Local"
     ```

2. **Azure Configuration**
   - Replace your Azure account information in `message.go` (lines 20-21):
     ```go
     accountName := os.Getenv("AZURE_STORAGE_ACCOUNT_NAME")
     accountKey := os.Getenv("AZURE_STORAGE_ACCOUNT_KEY")
     ```

## Installation

### 1. Frontend (Flutter)

1.1 **Clone the repository**  
   Run the following command to clone the frontend repository:
   ```bash
   git clone https://github.com/Joeleely/Readee.git
   ```

1.2 **Install dependencies** <br>
   Run this command
   ```
   flutter pub get
   ```

1.3 **Run the frontend** <br>
   Run this command
   ```
    flutter run
   ```
    
### 2. Backend 
    
2.1 **Clone the repository**  
Run the following command to clone the frontend repository:  
```bash
git clone https://github.com/parnlees/Readee-backend.git
```
2.2 **Install dependencies**  
Run this command to fetch required modules
```
go mod download
```
2.3 **Run the backend server**  
Run the backend server
```
go run main.go
```

### Members  
1. Name: Varanyu Leelasopin  
   Address: 343 Phraya Monthat, Bangbon, Bangbon 10150  
   Email: Varanyu.leel@kmutt.ac.th, Varanyu50015@gmail.com  
   Telephone Number: 083-076-2642  
2. Name: Yanisa Jaroenjan  
   Address: THAMMARAKSA dormitory, 126 Pracha Uthit Rd., Bang Mod, Thung Khru, Bangkok 10140  
   Email: yanisa.jaro@kmutt.ac.th , yanisa0439@gmail.com  
   Telephone Number: 0917268516
3. Name: Thanyakan Maneetool
   Address: 181/23 Pracha Uthit, Bangmod, Thung Kru 10140
   Email: thanyakanfs.33@gmail.com, thanyakan.mane@kmutt.ac.th  
   Telephone Number: 0814245955
