"""Smart Shop Management System"""

obj Shop {
    has name: str;
    has balance: float = 0.0;
    has income: float = 0.0;
    has expenses: float = 0.0;
    has inventory: dict[str, int] = {};      # product_name -> quantity
    has prices: dict[str, float] = {};        # product_name -> price

    def add_product(name: str, price: float, stock: int);
    def sell_product(name: str, quantity: int, customer: str);
    def restock(name: str, quantity: int, cost: float);
    def add_expense(amount: float, category: str);
    def report;
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

impl Shop.add_expense(amount: float, category: str) {
    self.expenses += amount;
    self.balance -= amount;
    print(f"Expense added: {category} = ${amount}");
}

impl Shop.report {
    print("------Shop Report 📊 ------");
    print(f"Total income: ${self.income}");
    print(f"Total Expenses: ${self.expenses}");
    print(f"Final Balance: ${self.balance}");

    print("\n🧮 Inventory Status:");

     # Iterate properly through dictionary items

    for name in self.inventory.keys() {
        qty = self.inventory[name];
        print(f" - {name}: {qty} units");
    }

    if self.balance > 0 {
        print("\n  Shop is profitable!");
    } elif self.balance == 0 {
        print("\n Shop is breaking even.");
    } else {
        print("\n  Shop is in deficit.");
    }
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


# 

with entry {

    shop = Shop(name="Smart Mart", balance=1000.0);
    print(f"Starting Shop System: {shop.name}");
    print(f"Initial Balance: ${shop.balance}");

    # Add products
    shop.add_product("Apple", 1.5, 50);
    shop.add_product("Banana", 0.8, 100);
    shop.add_product("Milk", 2.0, 30);

    # Restock one product
    shop.restock("Apple", 20, 25);

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


































