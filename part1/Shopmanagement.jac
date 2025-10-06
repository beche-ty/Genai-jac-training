"""Smart Shop Management System"""

obj Shop {
    has name: str;
    has balance: float = 0.0;
    has income: float = 0.0;
    has expenses: float = 0.0;
    has inventory: dict[str, int] = {};      # product_name -> quantity
    has prices: dict[str, float] = {}; 

    # adding a supplier

    has suppliers:list[Supplier] = [];

    def add_product(name: str, price: float, stock: int);
    def sell_product(name: str, quantity: int, customer: str);
    def restock(name: str, quantity: int, cost: float);
    
    def restock_credit(supplier: Supplier, name: str, quantity: int, cost: float);
    def pay_supplier(supplier:Supplier ,amount:float);

    def add_expense(amount: float, category: str);

    
    def report;
}


obj Supplier{
    has name:str;
    has balance_due:float =0.0;

    def deliver_item(shop:Shop,item:str, quantity:int, total_cost:float);
    def receive_payment(amount:float);

}

obj Customer {
    has name: str;
    has invoices: list[Invoice] = [];
} 


obj Invoice {
    has product: str;
    has quantity: int;
    has amount: float;
    has customer: str;
    has paid: bool = False;
    

    def pay(shop: Shop);
}


# ---------- Implementation ----------

impl Shop.add_product(name: str, price: float, stock: int) {
    self.inventory[name] = stock;
    self.prices[name] = price;
    print(f" Added product: {name} | Price: ${price} | Stock: {stock}");
}

impl Shop.sell_product(name: str, quantity: int, customer: str) {
    if name not in self.inventory {
        print(f" Product '{name}' not found in inventory.");
        return;
    }
    if self.inventory[name] < quantity {
        print(f" Not enough '{name}' in stock. Available: {self.inventory[name]}");
        return;
    }

    total = self.prices[name] * quantity;
    invoice = Invoice(product=name, quantity=quantity, amount=total, customer=customer);
    self.inventory[name] -= quantity;

    print(f"🧾 Sale recorded: {customer} bought {quantity}x {name} for ${total}");
    invoice.pay(self);
}

impl Shop.restock(name: str, quantity: int, cost: float) {
    if name not in self.inventory {
        self.inventory[name] = 0;
    }
    self.inventory[name] += quantity;
    self.expenses += cost;
    self.balance -= cost;
    print(f"Restocked {quantity}x {name} for ${cost}");
}
impl Shop.restock_credit(supplier:Supplier, name:str,quantity:int, cost:float) {
    if name not in self.inventory{
        self.inventory[name] =0;
    }
    self.inventory[name] +=quantity;
    supplier.deliver_item(self,name,quantity,cost);
}

impl Shop.pay_supplier(supplier:Supplier , amount:float){
    if self.balance < amount {
        print(f"Not enough funds to pay{supplier.name}.Current balance: ${self.balance}");
        return;
        }

    supplier.receive_payment(amount);
    self.balance -= amount;
    self.expenses += amount;
    print(f"Expense added: Supplier payment  = ${amount}");

}

impl Shop.add_expense(amount: float, category: str) {
    self.expenses += amount;
    self.balance -= amount;
    print(f"Expense added: {category} = ${amount}");
}

impl Shop.report {
    print("------Shop Financial Report 📊 ------");
    print(f"Total income: ${self.income}");
    print(f"Total Expenses: ${self.expenses}");
    print(f"Final Balance: ${self.balance}");

    print("\n🧮 inventory Status:");

     # Iterate properly through dictionary items

    for name in self.inventory.keys() {
        qty = self.inventory[name];
        print(f" - {name}: {qty} units");
    }

      print("\n📦 Supplier Balances:");

    for supplier in self.suppliers {
        print(f" - {supplier.name}: Owes ${supplier.balance_due}");

    if self.balance > 0 {
        print("\n  Shop is profitable!");
    } elif self.balance == 0 {
        print("\n Shop is breaking even.");
    } else {
        print("\n  Shop is in deficit.");
    }
}
}

# ---------- Supplier Implementation ----------

impl Supplier.deliver_item(shop: Shop, item: str, quantity: int, total_cost: float) {
    self.balance_due += total_cost;
    if self not in shop.suppliers {
        shop.suppliers.append(self);
    }
    print(f"🚚 Supplier {self.name} delivered {quantity}x {item} worth ${total_cost} (on credit)");
    print(f"🧾 {self.name} now owed: ${self.balance_due}");
}

impl Supplier.receive_payment(amount: float) {
    if amount > self.balance_due {
        print(f"⚠️ Overpayment attempt. Supplier {self.name} only owed ${self.balance_due}");
        return;
    }
    self.balance_due -= amount;
    print(f"✅ Supplier {self.name} received payment of ${amount}. Remaining due: ${self.balance_due}");
}

impl Invoice.pay(shop: Shop) {
    if not self.paid {
        self.paid = True;
        shop.income += self.amount;
        shop.balance += self.amount;
        print(f"✅ Payment received from {self.customer} for ${self.amount}");
        print(f"💵 New Shop Balance: ${shop.balance}");
    } else {
        print(f"Invoice already paid by {self.customer}");
    }
}




with entry {

    print("Starting Smart Shop Management Agent (with Suppliers)...\n");


    shop = Shop(name="Smart Mart", balance=1000.0);

    supplier1 = Supplier(name="FreshFruits Ltd");
    supplier2 = Supplier(name="DailyDairy Co");

    print(f"Starting Shop System: {shop.name}");
    print(f"Initial Balance: ${shop.balance}");

    # Add products
    shop.add_product("Apple", 1.5, 50);
    shop.add_product("Banana", 0.8, 100);
    shop.add_product("Milk", 2.0, 30);

   # Restock using credit from suppliers
    shop.restock_credit(supplier1, "Apple", 40, 60);
    shop.restock_credit(supplier2, "Milk", 50, 90);


    # Pay one supplier partially
    shop.pay_supplier(supplier1, 30);


    # Sell to customers
    shop.sell_product("Apple", 10, "Alice");
    shop.sell_product("Milk", 5, "Bob");
    shop.sell_product("Banana", 30, "Charlie");

    # Add expenses
    shop.add_expense(100, "Electricity");
    shop.add_expense(250, "Salaries");

    # Final report
    shop.report;
}


































