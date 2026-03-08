<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class ItemFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name'        => $this->faker->words(3, true),
            'description' => $this->faker->sentence(),
            'quantity'    => $this->faker->numberBetween(1, 100),
            'price'       => $this->faker->randomFloat(2, 1, 500),
        ];
    }
}
