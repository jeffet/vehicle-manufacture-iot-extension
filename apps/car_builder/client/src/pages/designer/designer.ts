/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import { Component, HostListener, OnInit } from '@angular/core';
import { NavController } from 'ionic-angular';

@Component({
  selector: 'page-designer',
  templateUrl: 'designer.html'
})
export class DesignerPage implements OnInit {
  cars: Object[];

  private numSlides = 1;

  constructor(public navController: NavController) {
    this.cars = [{
      name: 'Nebula',
      image: 'arium_nebula.svg',
      zoom: 'contain',
      repeat: 'no-repeat',
      position: 'right'
    }, {
      name: 'Nova',
      image: 'arium_nova.svg',
      zoom: 'contain',
      repeat: 'no-repeat',
      position: 'right'
    }, {
      name: 'Thanos',
      image: 'arium_thanos.svg',
      zoom: 'contain',
      repeat: 'no-repeat',
      position: 'right'
    }]
  }

  ngOnInit() {
    this.onResize({target: window });
  }

  @HostListener('window:resize', ['$event'])
  onResize(event) {
    this.numSlides = Math.floor(event.target.innerWidth / 300);

    if (this.numSlides < 1) {
      this.numSlides = 1;
    } else if (this.numSlides > this.cars.length) {
      this.numSlides = this.cars.length;
    }
  }
}
