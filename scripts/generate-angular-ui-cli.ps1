# ============================================================
#  B‑2 — Full CLEAN Angular UI CLI Generator (Modules-based)
# ============================================================

param()

$PROJECT = "angular-ui-cli"
$API_INVENTORY = "http://localhost:8082/inventory"
$API_CUSTOMERS = "http://localhost:8083/customers"
$API_ORDERS = "http://localhost:8081/orders"

Write-Host "=== REMOVING OLD PROJECT ==="
if (Test-Path $PROJECT) { Remove-Item -Recurse -Force $PROJECT }

# -------------------------------
Write-Host "=== CREATING ANGULAR PROJECT ==="
# -------------------------------
ng new $PROJECT --routing --style=scss --skip-git --package-manager=npm

Set-Location $PROJECT

Write-Host "=== INSTALLING ANGULAR HTTP PACKAGE ==="
npm install @angular/common@latest

# Ensure folder exists
New-Item -ItemType Directory -Force -Path "./src/app/models" | Out-Null
New-Item -ItemType Directory -Force -Path "./src/app/services" | Out-Null
New-Item -ItemType Directory -Force -Path "./src/app/components" | Out-Null

# ============================================================
#  MODELS
# ============================================================
@"
export interface InventoryItem {
  id: number;
  name: string;
  quantity: number;
  price: number;
}
"@ | Out-File ./src/app/models/inventory.model.ts -Encoding utf8 -Force

@"
export interface Customer {
  id: number;
  name: string;
  email: string;
}
"@ | Out-File ./src/app/models/customer.model.ts -Encoding utf8 -Force

@"
export interface Order {
  id: number;
  product: string;
  quantity: number;
  price: number;
}
"@ | Out-File ./src/app/models/order.model.ts -Encoding utf8 -Force


# ============================================================
#  SERVICES
# ============================================================

function Write-Service {
    param(
        [string]$Name,
        [string]$BaseUrl,
        [string]$File
    )

    $Content = @"
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ${Name} } from '../models/${Name}.model';

@Injectable({ providedIn: 'root' })
export class ${Name}Service {

    private BASE_URL = '$BaseUrl';

    constructor(private http: HttpClient) {}

    all(): Observable<${Name}[]> {
        return this.http.get<${Name}[]>(\`\${this.BASE_URL}\`);
    }

    get(id: number): Observable<${Name}> {
        return this.http.get<${Name}>(\`\${this.BASE_URL}/\${id}\`);
    }

    create(data: ${Name}): Observable<${Name}> {
        return this.http.post<${Name}>(\`\${this.BASE_URL}\`, data);
    }

    update(id: number, data: ${Name}): Observable<${Name}> {
        return this.http.put<${Name}>(\`\${this.BASE_URL}/\${id}\`, data);
    }

    delete(id: number): Observable<void> {
        return this.http.delete<void>(\`\${this.BASE_URL}/\${id}\`);
    }
}
"@

    $Content | Out-File $File -Encoding utf8 -Force
}

Write-Service "Customer"  "http://localhost:8083/customers" "./src/app/services/customer.service.ts"
Write-Service "InventoryItem" "http://localhost:8082/inventory" "./src/app/services/inventory.service.ts"
Write-Service "Order" "http://localhost:8081/orders" "./src/app/services/order.service.ts"



# ============================================================
#  COMPONENT GENERATION
# ============================================================
Write-Host "=== GENERATING CRUD COMPONENTS ==="

ng g c components/inventory-list --skip-tests
ng g c components/customer-list --skip-tests
ng g c components/order-list --skip-tests


# ============================================================
#  FILL COMPONENT HTML + TS
# ============================================================

# ================================================================
# FIXED COMPONENT GENERATOR (NO DUPLICATED "components" FOLDER)
# ================================================================

foreach ($entity in $Entities) {

    $Folder = "components/$($entity.Name)-list"
    $Class  = "$($entity.Name)ListComponent"

    # Ensure folder exists
    New-Item -ItemType Directory -Force -Path "./src/app/$Folder" | Out-Null

    # ---------------- HTML ----------------
    $HTML = @"
<h2>$($entity.Name) List</h2>

<button (click)="reload()">Reload</button>

<ul>
  <li *ngFor="let item of list">
    {{ item | json }}
    <button (click)="delete(item.id)">Delete</button>
  </li>
</ul>
"@

    $HTML | Out-File "./src/app/$Folder/$($entity.Name)-list.component.html" -Encoding utf8 -Force

    # ---------------- TS ----------------
    $TS = @"
import { Component, OnInit } from '@angular/core';
import { ${entity.Name}Service } from '../${entity.Name}service.service';
import { ${entity.Name} } from '../../models/${entity.Name}.model';

@Component({
  selector: '${entity.Name}-list',
  standalone: true,
  templateUrl: './${entity.Name}-list.component.html'
})
export class $Class implements OnInit {

  list: ${entity.Name}[] = [];

  constructor(private service: ${entity.Name}Service) {}

  ngOnInit(): void {
    this.reload();
  }

  reload(): void {
    this.service.all().subscribe(res => this.list = res);
  }

  delete(id: number): void {
    this.service.delete(id).subscribe(() => this.reload());
  }
}
"@

    $TS | Out-File "./src/app/$Folder/$($entity.Name)-list.component.ts" -Encoding utf8 -Force
}


# ============================================================
#  UPDATE ROUTING
# ============================================================
@"
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { InventoryListComponent } from './components/inventory-list/inventory-list.component';
import { CustomerListComponent } from './components/customer-list/customer-list.component';
import { OrderListComponent } from './components/order-list/order-list.component';

const routes: Routes = [
  { path: 'inventory', component: InventoryListComponent },
  { path: 'customers', component: CustomerListComponent },
  { path: 'orders', component: OrderListComponent },
  { path: '', redirectTo: 'inventory', pathMatch: 'full' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
"@ | Out-File ./src/app/app-routing.module.ts -Encoding utf8 -Force


# ============================================================
#  FINAL MESSAGE
# ============================================================
Write-Host "`n=== Angular UI CLI Successfully Generated (B‑2) ==="
Write-Host "Run using:"
Write-Host "   cd angular-ui-cli"
Write-Host "   npm start"
