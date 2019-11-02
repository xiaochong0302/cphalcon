<?php
declare(strict_types=1);

/**
 * This file is part of the Phalcon Framework.
 *
 * (c) Phalcon Team <team@phalcon.io>
 *
 * For the full copyright and license information, please view the LICENSE.txt
 * file that was distributed with this source code.
 */

namespace Phalcon\Test\Unit\Tag;

use UnitTester;

class CheckFieldCest
{
    /**
     * Tests Phalcon\Tag :: checkField()
     *
     * @author Phalcon Team <team@phalcon.io>
     * @since  2018-11-13
     */
    public function tagCheckField(UnitTester $I)
    {
        $I->wantToTest('Tag - checkField()');

        $I->skipTest('Need implementation');
    }
}