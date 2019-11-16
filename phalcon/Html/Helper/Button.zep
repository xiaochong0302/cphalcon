
/**
 * This file is part of the Phalcon Framework.
 *
 * (c) Phalcon Team <team@phalcon.io>
 *
 * For the full copyright and license information, please view the LICENSE.txt
 * file that was distributed with this source code.
 */

namespace Phalcon\Html\Helper;

/**
 * Phalcon\Html\Helper\Button
 *
 * Creates a button tag
 */
class Button extends AbstractHelper
{
    /**
     * @var string text       The text for the anchor
     * @var array  attributes Any additional attributes
     */
    public function __invoke(string! text, array attributes = []) -> string
    {
        return this->renderFullElement("button", text, attributes);
    }
}
