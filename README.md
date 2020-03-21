# Hospital-Management-System
SQL Database implementation of Hospital Management workflow 


# Database Specification:
* Purpose
* Business Rules
* Design Requirements
* Design Decisions
* ERD diagram

# Database Purpose:

The main purpose of the system is to:
* Design and maintain a database of the patient as well as employee details of the hospital
* It also includes the patients’ appointment, billing information, lab tests, disease history
* A feedback table is maintained in the database to store the feedbacks of the patients
* Reports are generated to visualize the data in a better manner

# Business Rules:

* Employee entity will have information of all hospital employee login information and which Admin (Employee) created other Employees (Doctor, Nurse, Lab assistant) 
* Employee Details will have information of Hospital employees (Admin, Doctor, Nurse, Lab Assistant) differentiated by Role.
* Patient has all demographic information related to Patient.
* Address can have multiple (current, previous) address for each patient and Hospital employees.
* Department has information related to hospital entities (Dental, Pediatric, Emergency, Physical therapy, etc.)
* Each doctor (Employee) may access one or more appointments.
* Each patient may check one or more appointments.
* Each patient may have more attendant (Doctor, Nurse, Lab assistant) per visit.
* Patient Register will have information of patient visit to hospital. One patient can have multiple visit.
* Feedback can be given by a Patient to a Hospital employee.
* Patient Billing will have information related to a Patient visit. It can also have multiple entry depend on type of changes (Transaction Type: Insurance bill, Attendant Bill, Lab Bill etc.)


# Design Requirements:

* Use Crow’s Foot Notation.
* Specify the primary key fields in each table by specifying PK beside the fields.
* Draw a line between the fields of each table to show the relationships between each table. This line should be pointed directly to the fields in each table that are used to form the relationship.
* Specify which table is on the one side of the relationship by placing a one next to the field where the line starts.
* Specify which table is on the many side of the relationship by placing a crow’s feet symbol next to the field where the line ends. 


# ER Diagram:

![](https://github.com/anwesh90/Hospital-Management-System/blob/master/ERD/Physical_DataModel.png)

