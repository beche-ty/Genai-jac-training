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
    has paid: bool = False;
    has customer: str;

    def pay(shop: Shop);
}


# ---------- Implementation ----------

impl Shop.add_product(name: str, price: float, stock: int) {
    self.inventory[name] = stock;
    self.prices[name] = price;
    print(f"🆕 Added product: {name} | Price: ${price} | Stock: {stock}");
}

impl Shop.sell_product(name: str, quantity: int, customer: str) {
    if name not in self.inventory {
        print(f"❌ Product '{name}' not found in inventory.");
        return;
    }
    if self.inventory[name] < quantity {
        print(f"⚠️ Not enough '{name}' in stock. Available: {self.inventory[name]}");
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
    print(f"📦 Restocked {quantity}x {name} for ${cost}");
}

impl Shop.add_expense(amount: float, category: str) {
    self.expenses += amount;
    self.balance -= amount;
    print(f"💸 Expense added: {category} = ${amount}");
}

impl Shop.report {
    print("------ 📊 Shop Report ------");
    print(f"Total Income: ${self.income}");
    print(f"Total Expenses: ${self.expenses}");
    print(f"Final Balance: ${self.balance}");

    print("\n🧮 Inventory Status:");
    for item, qty in self.inventory.items() {
        print(f" - {item}: {qty} units");

    if self.balance > 0 {
        print("\n✅ Shop is profitable!");
    } elif self.balance == 0 {
        print("\n⚖️ Shop is breaking even.");
    } else {
        print("\n❌ Shop is in deficit.");
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


# ---------- Run the Agent ----------

with entry {
    shop = Shop(name="Smart Mart", balance=1000.0);
    print(f"🏪 Starting Shop System: {shop.name}");
    print(f"💰 Initial Balance: ${shop.balance}");

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


































# # --- Nodes ---
# node Item {
#     has name: str;
#     has price: float;
#     has stock: int;
# }

# node Shop {
#     has name: str;
# }

# # --- Walker for stocking items ---
# walker Manager {
#     has item_name: str;
#     has item_price: float;
#     has item_stock: int;


#     can stock with Shop entry {
#         print(f"Manager is stocking {here.name}...");
#         item = here ++> Item(
#             name=self.item_name,
#             price=self.item_price,
#             stock=self.item_stock
#         );
#         print(f"  Added {item.name}, Price {item.price}, Stock {item.stock}");
#     }
# }

# # --- Walker for customers ---
# # walker Customer {
# #     has name: str;
# #     has cart: dict = {};   # each customer has their own cart

# #     # Browse items in the shop
# #     can browse with Shop entry {
# #         print(f"\n{self.name} is browsing {here.name}...");
# #         found = false;
# #         for e in here.edges(Item) {
# #             item = e.to;
# #             found = true;
# #             print(f"  {item.name} - Price: {item.price}, Stock: {item.stock}");
# #         }
# #         if not found {
# #             print("  (No items available)");
# #         }
# #     }

# #     # Buy an item
# #     can buy with Item entry {
# #         if here.stock > 0 {
# #             here.stock -= 1;
# #             self.cart[here.name] = self.cart.get(here.name, 0) + 1;
# #             print(f"{self.name} bought {here.name}!");
# #         } else {
# #             print(f"{here.name} is out of stock!");
# #         }
# #     }

# #     # Print receipt
# #     # can receipt with exit {
# #     #     print(f"\n--- Receipt for {self.name} ---");
# #     #     total = 0.0;
# #     #     for item_name in self.cart.keys() {
# #     #         qty = self.cart[item_name];
# #     #         for e in root.edges(Shop) {
# #     #             shop = e.to;
# #     #             for e2 in shop.edges(Item) {
# #     #                 shop_item = e2.to;
# #     #                 if shop_item.name == item_name {
# #     #                     price = shop_item.price;
# #     #                     line_total = price * qty;
# #     #                     print(f"{item_name} x{qty} @ {price} = {line_total}");
# #     #                     total += line_total;
# #     #             }
# #     #         }
# #     #     }
# #     #     print(f"TOTAL: {total}");
# #     #     print("----------------------------\n");
# #     # }
# # }

# # --- Entry program for cloud / default ---
# with entry {
#     # Create shop
#     shop = root ++> Shop(name="Corner Shop");

#     # Stock the shop
#     m = Manager();
#     m.item_name = "Apple";
#     m.item_price = 1.2;
#     m.item_stock = 5;
#     shop spawn m stock;

#     m = Manager();
#     m.item_name = "Milk";
#     m.item_price = 0.8;
#     m.item_stock = 3;
#     shop spawn m  stock;

#     m = Manager();
#     m.item_name = "Bread";
#     m.item_price = 1.5;
#     m.item_stock = 2;
#     shop spawn m  stock;

# }
#     # Customer Alice
#     # shop spawn Customer(name="Alice") with browse;

#     # items = [];
#     # for e in shop.edges(Item) {
#     #     items.append(e.to);
#     # }

#     # items[0] spawn Customer(name="Alice") with buy;   # Apple
#     # items[1] spawn Customer(name="Alice") with buy;   # Milk
#     # items[1] spawn Customer(name="Alice") with buy;   # Milk again
#     # root spawn Customer(name="Alice") with receipt;

#     # Customer Bob
#     # shop spawn Customer(name="Bob") with browse;

#     # items = [];
#     # for e in shop.edges(Item) {
#     #     items.append(e.to);
#     # }

#     # items[2] spawn Customer(name="Bob") with buy;     # Bread
#     # items[0] spawn Customer(name="Bob") with buy;     # Apple
#     # root spawn Customer(name="Bob") with receipt;
# }

# # --- CLI entry point ---
# # with entry:__main__ {
# #     root spawn Customer(name="Alice") with receipt;
# #     root spawn Customer(name="Bob") with receipt;
# # }
